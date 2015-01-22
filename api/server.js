#!/usr/bin/env node

process.chdir(__dirname);

require('coffee-script/register');

var app = require('./app');

port = process.env.PORT || 1338;
app.listen(port);

console.log('Listening at http://localhost:' + port);
