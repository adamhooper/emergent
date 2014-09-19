#!/usr/bin/env node

process.env.NODE_ENV = 'production'
process.chdir(__dirname + "/../frontend")
require('kexec')('npm start')
