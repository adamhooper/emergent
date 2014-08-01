#!/usr/bin/env node

process.chdir(__dirname + "/../editor")
require('kexec')('node_modules/sails/bin/sails.js lift' + (process.env.NODE_ENV == 'production' ? ' --prod' : ''))
