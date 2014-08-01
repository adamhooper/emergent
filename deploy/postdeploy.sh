#!/bin/sh

(cd "$(dirname "$0")"/.. && bin/npm-install-components.sh)
(cd "$(dirname "$0")"/../data-store && env NODE_ENV=production bin/sequelize db:migrate)
(cd "$(dirname "$0")"/../viewer && node_modules/.bin/gulp --require coffee-script/register prod)
