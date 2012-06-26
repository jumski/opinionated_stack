
applications = %w(akra_polska epics)

default['applications'] = applications.map do |name|
  {
    :username    => name,
    :password    => "#{name}_deploy_password",
    :db_username => name,
    :db_name     => name,
    :db_password => "#{name}_mysql_password"
  }
end

mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
