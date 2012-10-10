# Opinionated Stack

*WORK IN PROGRESS!!!*

Chef cookbook for bootstrapping multi-app rails stack.

## Installation

1. Setup hostname and fqdn for a server

  ```bash
  # /etc/hosts

  1.2.3.4 hostname hostname.domain.name
  ```

2. Clone it somewhere:

  ```bash
  git clone git@github.com:jumski/opinionated_stack.git /tmp/stack
  ```

3. Install it

  ```bash
  cd /tmp/stack
  ./install.sh
  ```

  When asked for mdadm arrays, leave "all".
  When asked for chef-server url, type "none".

4. Hopefully it will be all good now :-)

## Setting up applications

TODO!
