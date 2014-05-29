#!/bin/sh

# This script is used by awsbox to install dependencies for all apps.

NPM_ARGS="--production --cache-min 1209600" # 2 weeks

(cd editor && bower install --production)
(cd editor && npm install $NPM_ARGS)
(cd viewer && npm install $NPM_ARGS)
(cd popularity-fetcher && npm install $NPM_ARGS)
(cd bin && npm install --cache-min 1209600 kexec)
