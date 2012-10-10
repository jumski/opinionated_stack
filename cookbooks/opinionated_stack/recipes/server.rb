
akra = node[:akra]

akra[:packages].each { |name| package name }

group "deploy" do
  gid 2001
end

# unix user
user node[:nginx][:user] do
  gid "deploy"
end
include_recipe "nginx::default"

directory "/etc/supervisor.d" do
  group "deploy"
  mode "0770"
end

rvm_wrapper akra[:rvm_wrapper_prefix] do
  ruby_string "default@global"
  binary "bundle"
end

logrotate_app "redis" do
  cookbook "logrotate"
  path "/var/log/redis_6379.log"
  frequency "weekly"
  create "644 root adm"
  rotate 7
end

# nginx site config
template "/usr/bin/xvfb-wkhtmltopdf" do
  source "xvfb-wkhtmltopdf"
  mode '0755'
  owner "root"
  group "root"
end
