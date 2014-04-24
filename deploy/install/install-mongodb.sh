#!/bin/bash

set -e
set -x

cat <<EOT | sudo tee /etc/yum.repos.d/mongodb.repo
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
gpgcheck=0
enabled=1
EOT

sudo yum -y install mongodb-org

sudo chkconfig mongod on
sudo service mongod start
