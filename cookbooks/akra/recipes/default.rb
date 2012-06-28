
include_recipe "mysql::server"
include_recipe "database"
include_recipe "supervisor"
include_recipe "redisio::install"
include_recipe "redisio::enable"
include_recipe "rvm::system"

akra = node[:akra]

akra[:packages].each { |name| package name }

group "deploy" do
  gid 2001
end

# unix user
user node[:nginx][:user] do
  gid "deploy"
end
include_recipe "nginx::default"

directory "/etc/supervisor.d" do
  group "deploy"
  mode "0770"
end

rvm_wrapper akra[:rvm_wrapper_prefix] do
  ruby_string "default@global"
  binary "bundle"
end

###########################################
############# APPLICATIONS ################
###########################################
connection_info = {
  :host     => "localhost",
  :username => 'root',
  :password => node[:mysql][:server_root_password]
}

akra[:apps].each do |app|
  raise "Application name is required!" unless app[:name]
  raise "Application domains are required!" unless app[:domains].size > 0

  # override defaults for app with provided attributes
  app[:home_dir]    ||= "/home/#{app[:name]}"
  app[:username]    ||= app[:name]
  app[:group]       ||= 'deploy'
  app[:password]    ||= "#{app[:name]}_deploy_password"
  app[:db_username] ||= app[:name]
  app[:db_name]     ||= app[:name]
  app[:db_password] ||= "#{app[:name]}_mysql_password"
  app[:unicorn_worker_processes] ||= 1
  unicorn_socket_path = "#{app[:home_dir]}/current/tmp/unicorn.sock"

  # unix user
  user app[:username] do
    gid "deploy"
    home app[:home_dir]
    shell "/bin/bash"
    password %x[ openssl passwd -1 #{app[:password]} ].chomp!
    supports({:manage_home => true})
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
    privileges [:select, :update, :insert, :create, :drop]
    action :grant
  end

  # nginx site config
  template "/etc/nginx/sites-available/#{app[:name]}" do
    source "rails_site.erb"
    mode '0700'
    owner "root"
    group "root"
    variables(
      :domains     => app[:domains],
      :name        => app[:name],
      :socket_path => unicorn_socket_path,
      :root        => "#{app[:home_dir]}/current"
    )
  end

  %w(shared shared/log shared/config).each do |path|
    directory "#{app[:home_dir]}/#{path}" do
      owner app[:username]
      group "deploy"
      mode "0750"
      recursive true
    end
  end

  # nginx site config
  unicorn_config_path = "#{app[:home_dir]}/shared/config/unicorn_config.rb"
  template unicorn_config_path do
    source "unicorn_rails_config.erb"
    mode '0750'
    owner app[:username]
    group 'deploy'
    variables(
      :username         => app[:username],
      :group            => app[:group],
      :worker_processes => app[:unicorn_worker_processes],
      :socket_path      => unicorn_socket_path,
      :root             => "#{app[:home_dir]}/current",
      :timeout          => 30,
      :preload_app      => true
    )
  end

  # nginx site config
  template "#{app[:home_dir]}/shared/config/database.yml" do
    source "database.yml.erb"
    mode '0750'
    owner app[:username]
    group 'deploy'
    variables(
      :database => app[:db_name],
      :user     => app[:db_username],
      :password => app[:db_password]
    )
  end

  unicorn_command = "#{akra[:bundler_bin_path]} exec unicorn_rails -c #{unicorn_config_path} -E production"
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

