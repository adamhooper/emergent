module.exports =
  user:
    'get /login'               : 'AuthController.login'
    'get /logout'              : 'AuthController.logout'
    'get /auth/google'         : 'AuthController.google'
    'get /auth/google/callback': 'AuthController.googleCallback'

  editor:
    'get /': 'HomeController.home'

    'get /categories': 'CategoryController.index'

    'get    /stories'      : 'StoryController.index'
    'post   /stories'      : 'StoryController.create'
    'get    /stories/:slug': 'StoryController.find'
    'put    /stories/:slug': 'StoryController.update'
    'delete /stories/:slug': 'StoryController.destroy'

    'get    /stories/:slug/articles'    : 'ArticleController.index'
    'post   /stories/:slug/articles'    : 'ArticleController.create'
    'delete /stories/:slug/articles/:id': 'ArticleController.destroy'

    'get /tags': 'TagController.index'

    'get  /urls/:urlId/versions'              : 'UrlVersionController.index'
    'post /urls/:urlId/versions'              : 'UrlVersionController.create'
    'put  /urls/:urlId/versions/:urlVersionId': 'UrlVersionController.update'

    'get    /articles/:articleId/versions'           : 'ArticleVersionController.index'
    'post   /articles/:articleId/versions'           : 'ArticleVersionController.create'
    'put    /articles/:articleId/versions/:versionId': 'ArticleVersionController.update'
    'delete /articles/:articleId/versions/:versionId': 'ArticleVersionController.destroy'

    'get /unseen-articles': 'UnseenArticleController.index'

    'get /unparsed-urls': 'UnparsedUrlController.index'

    'get /dashboard/unparsed-domains': 'DashboardController.index_unparsed_domains'

    'get /user-submitted-claims': 'UserSubmittedClaimController.index'
    'patch /user-submitted-claims/:id': 'UserSubmittedClaimController.update'
