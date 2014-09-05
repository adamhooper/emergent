express = require('express')
fs = require('fs')

app = express()

if app.get('env') != 'test'
  morgan = require('morgan')
  app.use(morgan('tiny'))

if app.get('env') == 'production'
  app.enable('trust proxy')

for codeFile in fs.readdirSync("#{__dirname}/../controllers")
  [controllerName, ext] = codeFile.split(/\./)
  continue if ext != 'coffee' && ext != 'js'
  controller = require("#{__dirname}/../controllers/#{controllerName}")

  for action, func of controller
    [ method, path ] = action.split(/\s+/)
    app[method](path, func)

errorHandler = (err, req, res, next) ->
  if (res.statusCode < 400)
    res.status(500)
    console.warn(err.stack)

  res.json(message: err.message)

app.use(errorHandler)

module.exports = app
