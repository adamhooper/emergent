#!/usr/bin/env node

var express = require('express')
var app = express();
var serveStatic = require('serve-static');

app.use(serveStatic(__dirname + '/public'));
app.use(function(req, res) {
  res.sendFile(__dirname + '/views/index.html');
});

var port = process.env.PORT || 1339;
app.listen(port);
console.log('Listening at http://localhost:' + port);
