include_attribute 'rvm::default'

default[:akra_essentials].tap do |akra|

  # packages
  akra[:packages] = %w{
    libshadow-ruby1.8
    imagemagick
    libmagickcore-dev
  }

  akra[:rvm_wrapper_prefix] = 'sys'
  akra[:unicorn_bin_path]   = "/usr/local/rvm/bin/sys_unicorn_rails"

  akra[:apps] = %w(akra_polska epics).map do |name|
    {
      :name => name,
      :home_dir => home_dir = "/home/#{name}",
      :username => name,
      :password => "#{name}_deploy_password",
      :db_username => name,
      :db_name => name,
      :db_password => "#{name}_mysql_password",
      :domains => [],
      :unicorn_config_path => "#{home_dir}/unicorn_config.rb",
      :unicorn_socket_path => "#{home_dir}/current/tmp/unicorn.sock",
      :unicorn_worker_processes => 1,
    }
  end

  akra[:apps].find{|app| app[:name] == 'akra_polska'}.tap do |akra_polska|
    akra_polska[:domains] = %w(akra.net)
  end

  akra[:apps].find{|app| app[:name] == 'epics'}.tap do |epics|
    epics[:domains] = %w(epics.pl)
    epics[:unicorn_worker_processes] = 6
  end

end



# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
