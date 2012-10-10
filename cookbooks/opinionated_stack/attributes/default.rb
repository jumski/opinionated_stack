include_attribute 'rvm::default'
include_attribute 'postfix::default'
include_attribute 'nginx'

default[:opinionated_stack][:packages] = %w{
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
  xvfb
}
default[:opinionated_stack][:rvm_wrapper_prefix] = 'sys'
default[:opinionated_stack][:bundler_bin_path]   = "/usr/local/rvm/bin/sys_bundle"

# nginx defaults
nginx[:user] = "deploy"

# sudo
node['authorization']['sudo']['include_sudoers_d'] = true
node['authorization']['sudo']['agent_forwarding'] = true

postfix['mydomain'] = node[:opinionated_stack][:mail_domain]
postfix['myorigin'] = node[:opinionated_stack][:mail_domain]
postfix['smtp_use_tls'] = true
