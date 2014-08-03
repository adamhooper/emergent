module.exports =
  user:
    'get /login': 'AuthController.login'
    'get /logout': 'AuthController.logout'
    'get /auth/google': 'AuthController.google'
    'get /auth/google/callback': 'AuthController.googleCallback'

  editor:
    'get /': 'HomeController.home'
    'get /stories': 'StoryController.index'
    'get /stories/:slug': 'StoryController.find'
    'post /stories': 'StoryController.create'
    'put /stories/:slug': 'StoryController.update'
    'delete /stories/:slug': 'StoryController.destroy'

    'get /stories/:slug/articles': 'ArticleController.index'
    'post /stories/:slug/articles': 'ArticleController.create'
    'delete /stories/:slug/articles/:id': 'ArticleController.destroy'

    'get /urls/:urlId/versions': 'UrlVersionController.index'
    'post /urls/:urlId/versions': 'UrlVersionController.create'
    'put /urls/:urlId/versions/:urlVersionId': 'UrlVersionController.update'

    'get /articles/:articleId/versions': 'ArticleVersionController.index'
    'post /articles/:articleId/versions': 'ArticleVersionController.create'
    'put /articles/:articleId/versions/:versionId': 'ArticleVersionController.update'
