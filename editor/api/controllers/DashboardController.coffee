module.exports =
  index_unparsed_domains: (req, res) ->
    models.sequelize.query('''
      WITH url_id_popularity_by_service AS (
          SELECT "urlId" AS id, service, MAX(shares) AS shares
          FROM "UrlPopularityGet"
          GROUP BY "urlId", service
      ), url_id_popularity AS (
          SELECT id, SUM(shares) AS shares
          FROM url_id_popularity_by_service
          GROUP BY id
      ), urls AS (
          SELECT u.id, u.url, MAX(uv."parserVersion") AS null_iff_unparsed
          FROM "Url" u
          LEFT JOIN "UrlVersion" uv ON u.id = uv."urlId"
          GROUP BY u.id, u.url
      ), unparsed_urls_with_popularity AS (
          SELECT u.url, uip.shares
          FROM urls u
          INNER JOIN url_id_popularity uip ON u.id = uip.id
          WHERE u.null_iff_unparsed IS NULL
      ), unparsed_unaggregated_domains_with_popularity AS (
          SELECT url, SUBSTRING(url FROM '^[^:]+://([^/]*).*') AS domain, shares
          FROM unparsed_urls_with_popularity
      )
      SELECT domain, SUM(shares) AS shares, MAX(url) AS example_url
      FROM unparsed_unaggregated_domains_with_popularity
      GROUP BY domain
      ORDER BY SUM(shares) DESC
    ''')
    .then((rows) -> res.json(rows))
    .catch((e) -> res.status(e.status || 500).json(e))
