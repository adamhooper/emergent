module.exports.routes =
  'get /': 'HomeController.home'

  'get /login': 'AuthController.login',
  'get /logout': 'AuthController.logout',
  'get /register': 'AuthController.register',

  #'post /auth/local': 'AuthController.callback',
  #'post /auth/local/:action': 'AuthController.callback',

  'get /auth/:provider': 'AuthController.provider',
  'get /auth/:provider/callback': 'AuthController.callback',

  # Sails doesn't do nested routes nicely
  'get /stories/:slug/articles': 'ArticleController.index'
  'post /stories/:slug/articles': 'ArticleController.create'
  'delete /stories/:slug/articles/:id': 'ArticleController.destroy'
