
include_recipe "mysql::server"
include_recipe "database"
include_recipe "supervisor"
include_recipe "redisio::install"
include_recipe "redisio::enable"
include_recipe "rvm::system"
include_recipe "sudo"
include_recipe "logrotate"
include_recipe "postfix"
include_recipe "htpasswd"

include_recipe "opinionated_stack::server"
include_recipe "opinionated_stack::apps"


