opinionated_stack = node[:opinionated_stack]

###########################################
############# APPLICATIONS ################
###########################################
connection_info = {
  :host     => "localhost",
  :username => 'root',
  :password => node[:mysql][:server_root_password]
}

opinionated_stack[:apps].each do |app|
  raise "Application name is required!"        unless app[:name]
  raise "Application main_domain is required!" unless app[:main_domain].size > 0
  raise "Please provide a password!" unless app[:password]
  raise "Please provide a db_password!" unless app[:db_password]

  # override defaults for app with provided attributes
  app[:home_dir]    ||= "/home/#{app[:name]}"
  app[:username]    ||= app[:name]
  app[:group]       ||= 'deploy'
  app[:db_username] ||= app[:name]
  app[:db_name]     ||= app[:name]
  app[:unicorn_worker_processes] ||= 1
  app[:environment] ||= 'production'
  unicorn_socket_path = "#{app[:home_dir]}/shared/sockets/unicorn.sock"

  # http basic auth - check for usernames not included in httpasswd
  if app[:http_auth_for]
    bad_username = app[:http_auth_for].detect do |username|
      ! opinionated_stack[:httpasswd][:users][username]
    end

    if bad_username
      usernames = opinionated_stack[:httpasswd][:users].keys.join(', ')
      raise "User '#{bad_username}' expected to be present in httpasswd (#{usernames}), but is not."
    end
  end

  # unix user
  user app[:username] do
    gid "deploy"
    home app[:home_dir]
    shell "/bin/bash"
    password %x[ openssl passwd -1 #{app[:password]} ].chomp!
    supports({:manage_home => true})
  end

  directory app[:home_dir] do
    mode '0750'
  end

  bash "set permissions for .ssh and its contents" do
    user "root"
    code <<-EOH
      chmod 700 #{app[:home_dir]}/.ssh &&
        chmod 600 #{app[:home_dir]}/.ssh/*
    EOH
    only_if "test -d #{app[:home_dir]}/.ssh"
  end

  # mysql db with user
  mysql_database app[:db_name] do
    connection connection_info
    action :create
  end
  mysql_database_user app[:db_username] do
    connection connection_info
    password app[:db_password]
    database_name app[:db_name]
    host '%'
    privileges [:all]
    action :grant
  end

  # nginx site config
  template "/etc/nginx/sites-available/#{app[:name]}" do
    source "rails_site.erb"
    mode '0700'
    owner "root"
    group "root"
    variables(
      :main_domain      => app[:main_domain],
      :redirect_domains => app[:redirect_domains],
      :name             => app[:name],
      :socket_path      => unicorn_socket_path,
      :root             => "#{app[:home_dir]}/current",
      :asset_domain     => app[:asset_domain],
      :rails_serves_assets => app[:rails_serves_assets]
    )
    notifies :reload, "service[nginx]"
  end

  %w(bin shared shared/sockets shared/pids shared/log shared/config).each do |path|
    directory "#{app[:home_dir]}/#{path}" do
      owner app[:username]
      group "deploy"
      mode "0750"
      recursive true
    end
  end

  if app[:rolling_deploy]
    bash "set shared/sockets umask and unicorn socket permission" do
      user 'root'
      code "
        umask 0017
        if [ -f #{unicorn_socket_path} ]; then
          chmod g+rw #{unicorn_socket_path}
        fi
      "
    end
  end

  # nginx site config
  unicorn_config_path = "#{app[:home_dir]}/shared/config/unicorn_config.rb"
  unicorn_config_variables = {
    :username         => app[:username],
    :group            => app[:group],
    :worker_processes => app[:unicorn_worker_processes],
    :socket_path      => unicorn_socket_path,
    :root             => "#{app[:home_dir]}/current",
    :timeout          => 30,
    :preload_app      => true,
    :rolling_deploy   => app[:rolling_deploy],
  }
  if app[:rolling_deploy]
    unicorn_config_variables[:pidfile_path] = unicorn_pidfile_path = "#{app[:home_dir]}/shared/pids/unicorn.pid"
    unicorn_config_variables[:stderr_path]  = "#{app[:home_dir]}/shared/log/unicorn-err.log"
    unicorn_config_variables[:stdout_path]  = "#{app[:home_dir]}/shared/log/unicorn-out.log"
  end

  template unicorn_config_path do
    source "unicorn_rails_config.erb"
    mode '0750'
    owner app[:username]
    group 'deploy'
    variables(unicorn_config_variables)
  end

  # create restart scripts
  %w(start stop restart).each do |action|
    template_variables = {
      :root                => app[:home_dir],
      :name                => app[:name],
      :bundler_bin_path    => opinionated_stack[:bundler_bin_path],
      :unicorn_config_path => unicorn_config_path,
      :environment         => app[:environment]
    }
    template_path = if app[:rolling_deploy]
                      "#{action}_unicorn_rolling.erb"
                    else
                      "#{action}_unicorn_supervisor.erb"
                    end

    template "#{app[:home_dir]}/bin/#{action}" do
      source template_path
      mode '0750'
      owner app[:username]
      group 'deploy'
      variables template_variables
    end
  end

  # database.yml
  template "#{app[:home_dir]}/shared/config/database.yml" do
    source "database.yml.erb"
    mode '0750'
    owner app[:username]
    group 'deploy'
    variables(
      :database => app[:db_name],
      :user     => app[:db_username],
      :password => app[:db_password],
      :environment => app[:environment]
    )
  end

  # use supervisor only for simple sites without rolling deploy
  unless app[:rolling_deploy]
    sudo "#{app[:name]}_unicorn" do
      user app[:username]
      runas 'root'
      commands [
        "/usr/local/bin/supervisorctl pid #{app[:name]}_unicorn",
        "/usr/local/bin/supervisorctl status #{app[:name]}_unicorn",
        "/usr/local/bin/supervisorctl start #{app[:name]}_unicorn",
        "/usr/local/bin/supervisorctl stop #{app[:name]}_unicorn",
        "/usr/local/bin/supervisorctl restart #{app[:name]}_unicorn",
      ]
      host "ALL"
      nopasswd true
    end

    unicorn_command = "#{opinionated_stack[:bundler_bin_path]} exec unicorn_rails -c #{unicorn_config_path} -E #{app[:environment]}"
    supervisor_service "#{app[:name]}_unicorn" do
      action :enable
      command unicorn_command

      autostart false
      autorestart false
      user app[:username]
      stdout_logfile "#{app[:home_dir]}/shared/log/unicorn-out.log"
      stderr_logfile "#{app[:home_dir]}/shared/log/unicorn-err.log"
      directory "#{app[:home_dir]}/current"
    end
  end

  # create supervisor configs for resque workers
  if app[:resque_workers]
    app[:resque_workers].each do |name, queue|
      worker_name = "worker_#{name}"
      worker_service_name = "#{app[:name]}_#{worker_name}"

      supervisor_service worker_service_name do
        action :enable
        command "#{opinionated_stack[:bundler_bin_path]} exec rake resque:work RAILS_ENV=production VERBOSE=1 QUEUE=#{queue}"

        autostart true
        autorestart true
        user app[:username]
        stdout_logfile "#{app[:home_dir]}/shared/log/#{worker_name}-out.log"
        stderr_logfile "#{app[:home_dir]}/shared/log/#{worker_name}-err.log"
        directory "#{app[:home_dir]}/current"
      end

      # allow restarting workers by app user
      sudo "#{app[:name]}_workers" do
        user app[:username]
        runas 'root'
        commands [
          "/usr/local/bin/supervisorctl pid #{worker_service_name}",
          "/usr/local/bin/supervisorctl status #{worker_service_name}",
          "/usr/local/bin/supervisorctl start #{worker_service_name}",
          "/usr/local/bin/supervisorctl stop #{worker_service_name}",
          "/usr/local/bin/supervisorctl restart #{worker_service_name}",
        ]
        host "ALL"
        nopasswd true
      end

      # create binaries for worker actions
      template "#{app[:home_dir]}/bin/worker" do
        source 'worker_manager.erb'
        mode '0750'
        owner app[:username]
        group 'deploy'
        variables({
          :app_name => app[:name],
        })
      end
    end

    # create binaries for workers actions (used by capistrano)
    template "#{app[:home_dir]}/bin/workers" do
      source 'workers_restarter.erb'
      mode '0750'
      owner app[:username]
      group 'deploy'
      variables({
        :workers => app[:resque_workers]
      })
    end
  end

  dotfiles_path = "#{app[:home_dir]}/dotfiles"
  git dotfiles_path do
    repository "git://github.com/AkraPolska/dotfiles.git"
    reference "master"
    action :sync
  end
  directory dotfiles_path do
    owner app[:username]
    group 'deploy'
    recursive true
  end

end
