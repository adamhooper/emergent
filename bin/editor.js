#!/usr/bin/env node

process.env.NODE_ENV = 'production'
process.chdir(__dirname + "/../editor")
require('kexec')('node_modules/sails/bin/sails.js lift --prod')
