include_attribute 'rvm::default'

default[:akra_essentials][:packages] = %w{
  libshadow-ruby1.8
  imagemagick
  libmagickcore-dev
}
default[:akra_essentials][:rvm_wrapper_prefix] = 'sys'
default[:akra_essentials][:unicorn_bin_path]   = "/usr/local/rvm/bin/sys_unicorn_rails"

# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
