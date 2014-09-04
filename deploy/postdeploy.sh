#!/bin/sh

(cd "$(dirname "$0")"/.. && bin/npm-install-components.sh)
(cd "$(dirname "$0")"/../data-store && env NODE_ENV=production bin/sequelize db:migrate)
