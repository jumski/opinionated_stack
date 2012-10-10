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
  wkhtmltopdf
  git-core
}
default[:akra][:rvm_wrapper_prefix] = 'sys'
default[:akra][:bundler_bin_path]   = "/usr/local/rvm/bin/sys_bundle"

# nginx defaults
nginx[:user] = "deploy"

# sudo
node['authorization']['sudo']['include_sudoers_d'] = true
node['authorization']['sudo']['agent_forwarding'] = true

postfix['mydomain'] = node[:akra][:mail_domain]
postfix['myorigin'] = node[:akra][:mail_domain]
postfix['smtp_use_tls'] = true
