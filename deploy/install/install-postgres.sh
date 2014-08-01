#!/bin/bash

set -e
set -x

sudo yum -y install postgresql postgresql-server
sudo service postgresql initdb
sudo chkconfig postgresql on
sudo service postgresql start

cat <<EOT | sudo su postgres -c psql
CREATE USER truthmaker WITH PASSWORD 'truthmaker';
CREATE DATABASE truthmaker OWNER truthmaker;
EOT
