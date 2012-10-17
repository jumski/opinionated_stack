
opinionated_stack = node[:opinionated_stack]

opinionated_stack[:packages].each { |name| package name }

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

rvm_wrapper opinionated_stack[:rvm_wrapper_prefix] do
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

if opts = node[:opinionated_stack][:httpasswd]
  opts[:path] ||= "/etc/nginx/htpasswd"

  # delete actual file for the first run only
  action = :overwrite
  opts[:users].each_pair do |username, password|
    htpasswd opts[:path] do
      user username
      password password
      action action
    end

    # append rest of the users (do not delete)
    action = :add
  end
end
