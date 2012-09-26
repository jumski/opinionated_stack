### Akra Chef Repo for solo servers


## Installation

1. Install Akra dotfiles for root user (https://github.com/AkraPolska/dotfiles)

2. Setup hostname and fqdn for a server

  ```bash
  # /etc/hosts
  
  1.2.3.4 hostname hostname.domain.name
  ```

3. Clone chef-repo somewhere:

  ```bash
  git clone git@github.com:AkraPolska/chef-repo.git /tmp/chef-repo
  ```

4. Install it

  ```bash
  cd /tmp/chef-repo
  ./install.sh
  ```

5. Hopefully it will be all good now :-)

## Setting up applications