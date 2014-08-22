Article = global.models.Article
ArticleVersion = global.models.ArticleVersion
UrlVersion = global.models.UrlVersion

validArticle = (req) ->
  id = req.param('articleId') || '00000000-0000-0000-0000-000000000000'
  Article.find(id)
    .then (article) ->
      if article?
        article
      else
        throw { status: 404, message: "Article with id #{id} not found" }

validArticleVersion = (req) ->
  aid = req.param('articleId') || '00000000-0000-0000-0000-000000000000'
  vid = req.param('versionId') || '00000000-0000-0000-0000-000000000000'
  ArticleVersion.find(where: { id: vid, articleId: aid })
    .then (v) ->
      if v?
        v
      else
        throw { status: 404, message: "ArticleVersion with articleId #{aid} and id #{vid} not found" }

WriteableUrlVersionFields = [
  'source'
  'headline'
  'byline'
  'publishedAt'
  'body'
]

WriteableFields = [
  'stance'
  'headlineStance'
  'comment'
]

module.exports =
  index: (req, res) ->
    validArticle(req)
      .then((article) -> ArticleVersion.findAll(where: { articleId: article.id }, order: [ 'createdAt' ]))
      .then((versions) -> (v.toJSON() for v in versions))
      .then (versions) ->
        # Join UrlVersion
        urlVersionIds = (v.urlVersionId for v in versions)
        UrlVersion.findAll(where: { id: { in: urlVersionIds } })
          .then (urlVersions) ->
            idToUrlVersion = {}
            (idToUrlVersion[v.id] = v.toJSON()) for v in urlVersions
            for v in versions
              v.urlVersion = idToUrlVersion[v.urlVersionId]
              v
      .then((versions) -> res.json(versions))
      .catch((e) -> res.status(e.status || 500).json(e))

  create: (req, res) ->
    validArticle(req)
      .then (article) -> 
        row = { urlId: article.urlId }
        for k in WriteableUrlVersionFields
          row[k] = req.body.urlVersion?[k]
        row.publishedAt = new Date(row.publishedAt)
        UrlVersion.create(row, req.user.email)
          .then (urlVersion) ->
            row = { articleId: article.id, urlVersionId: urlVersion.id }
            for k in WriteableFields
              row[k] = req.body[k]
            ArticleVersion.create(row, req.user.email)
              .then (articleVersion) ->
                json = articleVersion.toJSON()
                json.urlVersion = urlVersion.toJSON()
                json
      .then((json) -> res.json(json))
      .catch((e) -> res.status(e.status || 500).json(e))

  update: (req, res) ->
    validArticleVersion(req)
      .then (av) ->
        UrlVersion.find(av.urlVersionId)
          .then (uv) ->
            row = {}
            (row[k] = req.body.urlVersion?[k]) for k in WriteableUrlVersionFields
            UrlVersion.update(uv, row, req.user.email)
          .then (uv) ->
            row = {}
            (row[k] = req.body[k]) for k in WriteableFields
            ArticleVersion.update(av, row, req.user.email)
              .then (av) ->
                json = av.toJSON()
                json.urlVersion = uv.toJSON()
                json
      .then((json) -> res.json(json))
      .catch((e) -> res.status(e.status || 500).json(e))

  destroy: (req, res) ->
    validArticleVersion(req)
      .then (av) ->
        ArticleVersion.destroy(id: av.id)
          .then -> UrlVersion.destroy(id: av.urlVersionId)
      .then(-> res.status(204).send(''))
      .catch((e) -> res.status(e.status || 500).json(e))
