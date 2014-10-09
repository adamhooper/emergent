#!/usr/bin/env node

process.env.NODE_ENV = 'production'
process.chdir(__dirname + "/../url-fetcher")
require('kexec')('npm start')
