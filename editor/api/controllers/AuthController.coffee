passport = require('passport')

requestToBaseUrl = (req) ->
  trustProxy = req.app.get('trust proxy')
  host = trustProxy && req.get('X-Forwarded-Host')
  host = host || req.get('Host')
  req.baseUrl = req.protocol + "://" + host

initializePassport = (anyRequest) ->
  baseUrl = requestToBaseUrl(anyRequest)

  GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
  try
    config = require('../../../../google-oauth-config.json')
  catch
    config = require('../../config/default-google-oauth-config.json')
    console.warn("Cannot load google-oauth-config.json from parent directory. Using default, for #{config.callbackURL}")
  config.scope = [ 'email' ]

  passport.use(new GoogleStrategy(config, (token, refreshToken, profile, done) ->
    email = profile.emails[0].value
    models.User.find(where: { email: email })
      .then((maybeUser) -> maybeUser || false)
      .nodeify(done)
  ))

module.exports = AuthController =
  # Render the login page
  login: (req, res) ->
    res.render('auth/login.jade')

  # Log out a user and return them to the homepage
  #
  # Passport exposes a logout() function on req (also aliased as logOut()) that
  # can be called from any route handler which needs to terminate a login
  # session. Invoking logout() will remove the req.user property and clear the
  # login session (if any).
  #
  # For more information on logging out users in Passport.js, check out:
  # http://passportjs.org/guide/logout/
  logout: (req, res) ->
    req.logout()
    res.redirect('/')

  google: (req, res) ->
    if !@initialized
      initializePassport(req)
      @initialized = true

    passport.authenticate('google')(req, res)

  googleCallback: passport.authenticate('google', 
    successRedirect: '/'
    failureRedirect: '/login'
  )
