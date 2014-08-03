passport = require('passport')

module.exports =
  initialize: (app) ->
    app.use(passport.initialize())
    app.use(passport.session())

    passport.serializeUser (user, done) ->
      done(null, user.id)

    passport.deserializeUser (id, done) ->
      models.User.find(id)
        .then((maybeUser) -> maybeUser || false)
        .nodeify(done)
