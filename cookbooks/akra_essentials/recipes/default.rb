
include_recipe "mysql::server"
include_recipe "database"
include_recipe "supervisor"
include_recipe "nginx::default"
include_recipe "redisio::install"
include_recipe "redisio::enable"
include_recipe "rvm::system"

akra = node[:akra_essentials]

akra[:packages].each do |name|
  puts '----------------'
  puts name.inspect
  package name
end

group "deploy" do
  gid 2001
end

directory "/etc/supervisor.d" do
  group "deploy"
  mode "770"
end

rvm_wrapper akra[:rvm_wrapper_prefix] do
  ruby_string "default@global"
  binary "unicorn_rails"
end

###########################################
############# APPLICATIONS ################
###########################################
connection_info = {
  :host     => "localhost",
  :username => 'root',
  :password => node[:mysql][:server_root_password]
}
#   # unix user
#   user app[:username] do
#     gid "deploy"
#     home app[:home_dir]
#     shell "/bin/bash"
#     password %x[ openssl passwd -1 #{app[:password]} ].chomp!
#     supports({:manage_home => true})
#   end
#
#   # mysql db with user
#   mysql_database app[:db_name] do
#     connection connection_info
#     action :create
#   end
#   mysql_database_user app[:db_username] do
#     connection connection_info
#     password app[:db_password]
#     database_name app[:db_name]
#     host '%'
#     privileges [:select, :update, :insert, :create, :drop]
#     action :grant
#   end
#
#   # nginx site config
#   template "/etc/nginx/sites-available/#{name}" do
#     source "rails_site.erb"
#     mode 700
#     owner "root"
#     group "root"
#     variables(
#       :domains     => app[:domains].map{|d| [d, "www.#{d}"]}.flatten,
#       :name        => name,
#       :socket_path => app[:unicorn_socket_path],
#       :root        => "#{app[:home_dir]}/current"
#     )
#   end
#
#   # nginx site config
#   template app[:unicorn_config_path] do
#     source "unicorn_rails_config.erb"
#     mode 700
#     owner app[:username]
#     group 'deploy'
#     variables(
#       :username         => app[:username],
#       :group            => app[:group],
#       :worker_processes => app[:unicorn_worker_processes],
#       :root             => "#{app[:home_dir]}/current",
#       :timeout          => 30,
#       :preload_app      => true
#     )
#   end
#
#   supervisor_service "#{name}_unicorn" do
#     action :enable
#     command "#{a}"
#
#     autostart true
#     autorestart false
#     user "deploy"
#     stdout_logfile "#{app[:home_dir]}/current/log/unicorn-out.log"
#     stderr_logfile "#{app[:home_dir]}/current/log/unicorn-err.log"
#     directory "#{app[:home_dir]}/current"
#   end
#
# end

