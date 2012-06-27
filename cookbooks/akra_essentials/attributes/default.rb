
default['akra_essentials'].tap do |akra|

  # packages
  akra['packages'] = %w{
    libshadow-ruby1.8
    imagemagick
    libmagickcore-dev
  }

  # akra[:rvm_wrapper_prefix] = 'sys'
  # hax = "#{default['rvm']['root_path']}/#{akra[:rvm_wrapper_prefix]}_"
  # akra['rvm_wrapper_path_prefix'] = hax
  # akra['unicorn_bin_path'] = "#{akra[:rvm_wrapper_path_prefix]}unicorn"
  akra['rvm_wrapper_path_prefix'] = 'hax'
  akra['unicorn_bin_path'] = 'hax'

  # create basic app values based on app name
  %w(akra_polska epics).each do |name|
    akra['apps'][name]['name']        = name
    akra['apps'][name]['home_dir']    = "/home/#{name}"
    akra['apps'][name]['username']    = name
    akra['apps'][name]['password']    = "#{name}_deploy_password"
    akra['apps'][name]['db_username'] = name
    akra['apps'][name]['db_name']     = name
    akra['apps'][name]['db_password'] = "#{name}_mysql_password"
    akra['apps'][name]['domains']     = []
    akra['apps'][name]['unicorn_config_path'] = "#{akra['apps'][name]['home_dir']}/shared/config/unicorn.rb"
    akra['apps'][name]['unicorn_socket_path'] = "#{akra['apps'][name]['home_dir']}/current/tmp/unicorn.sock"
    akra['apps'][name]['unicorn_worker_processes'] = 1
  end

  raise akra['apps']['epics']['name'].inspect

  # overrides
  akra['apps'].tap do |apps|
    apps['akra_polska']['domains'] = %w(akra.net)
    apps['epics']['domains']       = %w(epics.pl)
    apps['epics']['unicorn_worker_processes'] = 6
  end

end

# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
