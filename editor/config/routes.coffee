module.exports.routes =
  'get /': 'HomeController.home'

  'get /login': 'AuthController.login',
  'get /logout': 'AuthController.logout',
  'get /register': 'AuthController.register',

  #'post /auth/local': 'AuthController.callback',
  #'post /auth/local/:action': 'AuthController.callback',

  'get /auth/:provider': 'AuthController.provider',
  'get /auth/:provider/callback': 'AuthController.callback',

  'get /stories': 'StoryController.index'
  'get /stories/:slug': 'StoryController.find'
  'post /stories': 'StoryController.create'
  'put /stories/:slug': 'StoryController.update'
  'delete /stories/:slug': 'StoryController.destroy'

  # Sails doesn't do nested routes nicely
  'get /stories/:slug/articles': 'ArticleController.index'
  'post /stories/:slug/articles': 'ArticleController.create'
  'put /stories/:slug/articles/:id': 'ArticleController.update'
  'delete /stories/:slug/articles/:id': 'ArticleController.destroy'
