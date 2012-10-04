include_attribute 'rvm::default'
include_attribute 'postfix::default'

default[:akra][:packages] = %w{
  libshadow-ruby1.8
  imagemagick
  libmagickcore-dev
  vim-nox
  htop
  ack-grep
  emacs
  tree
  htop
  tig
}
default[:akra][:rvm_wrapper_prefix] = 'sys'
default[:akra][:bundler_bin_path]   = "/usr/local/rvm/bin/sys_bundle"

# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"

# nginx defaults
nginx[:user] = "deploy"

# sudo
node['authorization']['sudo']['include_sudoers_d'] = true

postfix['mydomain'] = node[:akra][:mail_domain]
postfix['myorigin'] = node[:akra][:mail_domain]
postfix['smtp_use_tls'] = true
