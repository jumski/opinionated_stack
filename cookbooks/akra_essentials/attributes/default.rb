
# create basic app values based on app name
%w(akra_polska epics).each do |name|
  default['akra_essentials']['apps'][name] = {
    :name        => name,
    :home_dir    => "/home/#{name}",
    :username    => name,
    :password    => "#{name}_deploy_password",
    :db_username => name,
    :db_name     => name,
    :db_password => "#{name}_mysql_password",
    :domains     => []
  }
end

# overrides
default['akra_essentials']['apps'].tap do |apps|
  apps['akra_polska']['domains'] = %w(akra.net)
  apps['epics']['domains']       = %w(epics.pl)
end

# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
