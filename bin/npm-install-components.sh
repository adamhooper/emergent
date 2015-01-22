#!/bin/sh

# This script installs npm dependencies for all apps.

DIR="$(dirname "$0")/.."
NPM_ARGS="--cache-min 1209600" # 2 weeks

(cd "$DIR"/api && npm install $NPM_ARGS)
(cd "$DIR"/data-store && npm install $NPM_ARGS)
(cd "$DIR"/editor && npm install $NPM_ARGS)
(cd "$DIR"/frontend && npm install $NPM_ARGS)
(cd "$DIR"/job-queue && npm install $NPM_ARGS)
(cd "$DIR"/url-fetcher && npm install $NPM_ARGS)
