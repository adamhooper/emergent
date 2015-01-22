#!/bin/sh

# This gets run on a web server. It compiles assets and then restarts the
# server.

DIR="$(dirname "$0")/.."

"$DIR"/bin/install-components.sh
"$DIR"/bin/compile-all.sh

pm2 startOrRestart ecosystem.json
