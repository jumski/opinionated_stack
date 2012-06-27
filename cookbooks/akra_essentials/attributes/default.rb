
default[:akra_essentials].tap do |akra|

  # packages
  akra[:packages] = %w{
    libshadow-ruby1.8
    imagemagick
    libmagickcore-dev
  }

  akra[:rvm_wrapper_prefix] = 'sys'


  akra['apps'] = %w(akra_polska epics).map do |name|
    {
      :name => name,
      :home_dir => home_dir = "/home/#{name}",
      :username => name,
      :password => "#{name}_deploy_password",
      :db_username => name,
      :db_name => name,
      :db_password => "#{name}_mysql_password",
      :domains => [],
      :unicorn_config_path => "#{home_dir}/shared/config/unicorn.rb",
      :unicorn_socket_path => "#{home_dir}/current/tmp/unicorn.sock",
      :unicorn_worker_processes => 1,
    }
  end

end

# akra['rvm_wrapper_path_prefix'] = hax
# akra['unicorn_bin_path'] = "#{akra[:rvm_wrapper_path_prefix]}unicorn"
# akra['rvm_wrapper_path_prefix'] = 'hax'
# akra['unicorn_bin_path'] = 'hax'

#   # create basic app values based on app name

# raise akra['apps']['epics']['name'].inspect
#
# # overrides
# akra['apps'].tap do |apps|
#   apps['akra_polska']['domains'] = %w(akra.net)
#   apps['epics']['domains']       = %w(epics.pl)
#   apps['epics']['unicorn_worker_processes'] = 6
# end

# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
