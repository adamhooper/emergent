#!/bin/sh

(cd "$(dirname "$0")"/.. && bin/npm-install-components.sh)
(cd "$(dirname "$0")"/../viewer && node_modules/.bin/gulp --require coffee-script/register prod)
