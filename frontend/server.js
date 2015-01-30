#!/usr/bin/env node

process.chdir(__dirname);

var express = require('express')
var morgan = require('morgan');
var serveStatic = require('serve-static');

var app = express();

switch (app.get('env')) {
  case 'production':
    app.use(morgan('combined'));
    app.enable('trust proxy');
    break;
  case 'test':
    break;
    logMode = 'combined'; break;
  default:
    app.use(morgan('dev'));
}

app.use(serveStatic(__dirname + '/public'));
app.use(function(req, res) {
  res.sendFile(__dirname + '/views/' + (process.env.NODE_ENV=='development' ? 'dev.html' : 'index.html'));
});

var port = process.env.PORT || 1339;
app.listen(port);
console.log('Listening at http://localhost:' + port);
