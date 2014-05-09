#!/bin/sh

# This script is used by awsbox to install dependencies for all apps.

(cd editor && bower install --production)
(cd editor && npm install --production)
