#!/bin/sh

DIR="$(dirname "$0")/.."

"$DIR"/bin/npm-install-components.sh
(cd "$DIR"/frontend && bundle install)
