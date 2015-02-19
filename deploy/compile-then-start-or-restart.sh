#!/bin/sh

# This gets run on a web server. It compiles assets and then restarts the
# server.

set -e
set -x

DIR="$(dirname "$0")/.."

"$DIR"/bin/install-components.sh
"$DIR"/bin/compile-all.sh
(cd "$DIR"/data-store && env NODE_ENV=production bin/sequelize db:migrate)
"$DIR"/bin/test-all.sh

pm2 startOrRestart ecosystem.json --env production
