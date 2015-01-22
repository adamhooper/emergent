#!/bin/sh

DIR="$(dirname "$0")/.."

(cd "$DIR"/editor && node_modules/.bin/gulp prod)
(cd "$DIR"/frontend && bundle exec node_modules/.bin/grunt dist)
