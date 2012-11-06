include_attribute 'rvm::default'
include_attribute 'postfix::default'
include_attribute 'nginx'

default[:opinionated_stack][:remove_packages] = %w{
  apache2-mpm-prefork apache2.2-bin apache2-doc apache2.2-common apache2
}
default[:opinionated_stack][:install_packages] = %w{
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
  apt-file
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
