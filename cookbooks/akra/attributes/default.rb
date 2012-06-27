include_attribute 'rvm::default'

default[:akra][:packages] = %w{
  libshadow-ruby1.8
  imagemagick
  libmagickcore-dev
}
default[:akra][:rvm_wrapper_prefix] = 'sys'
default[:akra][:unicorn_bin_path]   = "/usr/local/rvm/bin/sys_unicorn_rails"

# mysql passwords
mysql["server_root_password"]   = "akrapolskalubimysql"
mysql["server_repl_password"]   = "akrapolskalubimysql"
mysql["server_debian_password"] = "akrapolskalubimysql"
