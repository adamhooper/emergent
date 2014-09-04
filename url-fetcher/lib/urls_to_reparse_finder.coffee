models = require('../../data-store').models

module.exports = class UrlsToReparseFinder
  constructor: (options) ->
    @htmlParser = options?.htmlParser || require('./parser/html_parser')

  findUrlsToReparse: (done) ->
    models.sequelize.query('''
      WITH "rankedLastVersions" AS (
            SELECT "urlId", "parserVersion", rank() OVER (PARTITION BY "urlId" ORDER BY "createdAt" DESC) AS r
                  FROM "UrlVersion"
                          WHERE "parserVersion" IS NOT NULL
      )
      SELECT u.id, u.url, v."parserVersion" AS "lastParserVersion" 
      FROM "Url" u 
      LEFT JOIN "rankedLastVersions" v ON u.id = v."urlId"
      WHERE v.r IS NULL OR v.r = 1
    ''')
      .then (rows) =>
        for row in rows
          siteParser = @htmlParser.urlToSiteParser(row.url)
          if siteParser
            row.currentParserVersion = siteParser.version
        row for row in rows when 'currentParserVersion' of row && (row.currentParserVersion > (row.lastParserVersion || 0))
      .nodeify(done)
