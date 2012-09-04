#!/bin/bash

# apt-get install sudo wget lsb-release
# echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | tee /etc/apt/sources.list.d/opscode.list
# mkdir -p /etc/apt/trusted.gpg.d
# gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
# gpg --export packages@opscode.com | tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
# apt-get update
# apt-get install opscode-keyring
# apt-get upgrade
# apt-get install chef

mkdir -p /var/chef-solo
git clone git@github.com:AkraPolska/chef-repo.git /var/chef-solo/chef-repo
pushd /var/chef-solo/chef-repo
git submodule update --init
popd

rm /etc/chef/client.rb

if ! test -f /etc/chef/dna.json; then
  cp /var/chef-solo/chef-repo/chef-etc/dna.json /etc/chef
fi

if ! test -f /etc/chef/solo.rb; then
  cp /var/chef-solo/chef-repo/chef-etc/solo.rb /etc/chef
fi

vim -p /etc/chef/*
ln -sf /var/chef-solo/chef-repo/chef-run /usr/bin/chef-run