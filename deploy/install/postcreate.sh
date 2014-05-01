#!/bin/sh

"$(dirname "$0")"/install-mongodb.sh
"$(dirname "$0")"/install-redis.sh

sudo npm install -g bower
