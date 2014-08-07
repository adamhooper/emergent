express = require('express')
bodyParser = require('body-parser')

for k, v of require('../config/globals')
  global[k] = v

app = express()

app.use(bodyParser.urlencoded(extended: false))
app.use(bodyParser.json())

if app.get('env') != 'test'
  morgan = require('morgan')
  session = require('express-session')
  RedisStore = require('connect-redis')(session)

  app.use(morgan('tiny'))

  SessionAgeInS = 86400 * 7 # one week
  sess =
    store: new RedisStore
      ttl: SessionAgeInS
    # FIXME this isn't really secret. It's published on GitHub.
    secret: 'b8a167887d3da5131f161cd0447741d18595163c0ec4fa820cb87c31098d10639accaf90242db27c6b077c17f5615a2ce70c5cece66a1b1210db83bfc8187ec542580379d2142785764692b5532d3acc710fa2612a27b943384aebdf68ebce558baf0f1d73c53f729762d8e5718480256e06c96ddbd635d8'
    resave: true
    saveUninitialized: true
    cookie:
      maxAge: SessionAgeInS * 1000

  if app.get('env') == 'production'
    app.enable('trust proxy')
    sess.cookie.secure = true

  app.use(session(sess))

  require('./passport').initialize(app)
else
  # Stub out req.user for unit tests
  app.use((req, res, next) -> req.user = { email: 'user@example.org' }; next())

# Pass "user" to views
app.use (req, res, next) ->
  res.locals.user = req.user
  next()

authenticate = (role) ->
  (req, res, next) ->
    if role == 'editor' && !req.user
      res.redirect('/login')
    else
      next()

addRoutes = (app) ->
  # Adds ('user', 'get /', 'HomeController.home') to app
  addRoute = (role, k, v) ->
    [ method, path ] = k.split(/\s+/)
    [ controllerName, funcName ] = v.split(/\./)
    func = require("../api/controllers/#{controllerName}")[funcName]
    app[method](path, authenticate(role), func)

  # Calls addRoute() with the contents of config/routes
  for role, routes of require('../config/routes')
    for k, v of routes
      addRoute(role, k, v)

  undefined

addRoutes(app)

app.use(express.static("#{__dirname}/../.tmp/public"))

module.exports = app
