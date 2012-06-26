
# include_recipe "mysql"
include_recipe "supervisor"

group "deploy" do
  gid 2001
end

package "libshadow-ruby1.8"

user "deploy" do
  comment "Random User"
  uid 2001
  gid "deploy"
  home "/home/deploy"
  shell "/bin/bash"
  password "$1$WOnSGbsW$jGaquFTfyPRccRQ9w1p3/1"
  supports({:manage_home => true})
end

# mysql["server_root_password"]   = "akrapolskalubimysql"
# mysql["server_repl_password"]   = "akrapolskalubimysql"
# mysql["server_debian_password"] = "akrapolskalubimysql"
