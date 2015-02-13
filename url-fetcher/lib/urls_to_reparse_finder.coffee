models = require('../../data-store').models

module.exports = class UrlsToReparseFinder
  constructor: (options) ->
    @htmlParser = options?.htmlParser || require('./parser/html_parser')

  findUrlsToReparse: (done) ->
    models.sequelize.query('''
      SELECT u.id, u.url, MAX(uv."parserVersion") AS "lastParserVersion"
      FROM "Url" u 
      LEFT JOIN "UrlVersion" uv ON u.id = uv."urlId"
      GROUP BY u.id, u.url
    ''', null, type: 'SELECT')
      .then (rows) =>
        for row in rows
          siteParser = @htmlParser.urlToSiteParser(row.url)
          if siteParser
            row.currentParserVersion = siteParser.version
        row for row in rows when 'currentParserVersion' of row && (row.currentParserVersion > (row.lastParserVersion || 0))
      .nodeify(done)
