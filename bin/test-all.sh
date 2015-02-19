#!/bin/sh

set -x
set -e

DIR="$(dirname "$0")/.."

(cd "$DIR"/api && npm test)
(cd "$DIR"/editor && npm test)
(cd "$DIR"/url-fetcher && npm test)
