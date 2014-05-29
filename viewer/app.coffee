express = require('express')
morgan = require('morgan') # logger

app = express()

(->
  global[k] = v for k, v of require('./config/globals')
)()
require('./config/routes')(app)

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(morgan(format: 'dev'))
app.use(express.static(__dirname + '/.tmp/public'))

app.listen(1338)
console.log("Listening on port 1338")
