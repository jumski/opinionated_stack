
include_recipe "mysql::server"
include_recipe "database"
include_recipe "supervisor"

package "libshadow-ruby1.8"

group "deploy" do
  gid 2001
end

directory "/etc/supervisor.d" do
  group "deploy"
  mode "770"
end

connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

node['akra_essentials']['apps'].each do |app|

  user app[:username] do
    gid "deploy"
    home "/home/#{app[:username]}"
    shell "/bin/bash"
    password %x[ openssl passwd -1 #{app[:password]} ].chomp!
    supports({:manage_home => true})
  end

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

end

