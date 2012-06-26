
include_recipe "mysql::server"
include_recipe "supervisor"

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

group "deploy" do
  gid 2001
end

directory "/etc/supervisor.d" do
  group "deploy"
  mode "770"
end

