#!/bin/sh

"$(dirname "$0")"/install-postgres.sh
"$(dirname "$0")"/install-redis.sh

sudo npm install -g bower
