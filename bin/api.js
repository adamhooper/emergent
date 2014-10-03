#!/usr/bin/env node

process.env.NODE_ENV = 'production'
process.chdir(__dirname + "/../api")
require('kexec')('npm start')
