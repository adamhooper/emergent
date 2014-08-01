#!/bin/bash

set -e
set -x

sudo yum -y install postgresql postgresql-server postgresql-devel
sudo service postgresql initdb
sudo sed -i -e 's/ident$/md5/' /var/lib/pgsql9/data/pg_hba.conf
sudo chkconfig postgresql on
sudo service postgresql start

cat <<EOT | sudo su postgres -c psql
CREATE USER truthmaker PASSWORD 'truthmaker';
CREATE DATABASE truthmaker OWNER truthmaker ENCODING 'utf-8';
EOT
