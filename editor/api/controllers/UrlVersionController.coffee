Url = global.models.Url
UrlVersion = global.models.UrlVersion

# Verifies that the Url is in the database, as a Promise.
#
# On success: returns a URL id.
# On failure: returns an Error.
getValidUrlId = (req) ->
  id = req.param('urlId') || '0000000-0000-0000-0000-000000000000'
  Url.find(id)
    .then (url) ->
      if !url
        throw { status: 404, message: "Url with id #{id} not found" }
      else
        id

WriteableFields = [
  'source'
  'headline'
  'byline'
  'publishedAt'
  'body'
]

parseRow = (body) ->
  row = {}
  (row[f] = body[f]) for f in WriteableFields
  row.publishedAt = new Date(row.publishedAt)
  row

module.exports =
  index: (req, res) ->
    getValidUrlId(req)
      .then (urlId) -> UrlVersion.findAll(where: { urlId: urlId }, order: [ 'createdAt' ])
      .then (versions) -> res.json(200, versions)
      .catch (e) -> res.json(e.status || 500, e)

  create: (req, res) ->
    getValidUrlId(req)
      .then (urlId) ->
        row = parseRow(req.body)
        row.urlId = urlId
        UrlVersion.create(row, req.user.email)
      .then (version) -> res.json(200, version)
      .catch (e) -> res.json(e.status || 500, e)

  update: (req, res) ->
    urlId = req.param('urlId') || '0000000-0000-0000-0000-000000000000'
    urlVersionId = req.param('urlVersionId') || '0000000-0000-0000-0000-000000000000'
    UrlVersion.find(where: { id: urlVersionId, urlId: urlId })
      .then (urlVersion) ->
        if urlVersion?
          row = parseRow(req.body)
          UrlVersion.update(urlVersion, row, req.user.email)
        else
          throw { status: 404, message: "UrlVersion not found" }
      .then (version) -> res.json(200, version)
      .catch (e) -> res.json(e.status || 500, e)
