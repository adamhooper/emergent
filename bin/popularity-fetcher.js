#!/usr/bin/env node

process.chdir(__dirname + "/../popularity-fetcher")
require('kexec')('npm start')
