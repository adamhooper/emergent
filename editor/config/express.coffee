# Configure advanced options for the Express server inside of Sails.
#
# For more information on configuration, check out:
# http://sailsjs.org/#documentation
module.exports.express =
  customMiddleware: (app) ->
    app.enable('trust proxy')
    # Use Passport
    app.use(passport.initialize())
    app.use(passport.session())

module.exports.cache =
	maxAge: 0
