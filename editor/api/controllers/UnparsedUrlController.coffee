module.exports =
  index: (req, res) ->
    models.sequelize.query('SELECT url FROM "Url" WHERE id NOT IN (SELECT DISTINCT "urlId" FROM "UrlVersion" WHERE "createdBy" IS NULL) ORDER BY url', null, raw: true)
      .then((urls) -> res.json(u.url for u in urls))
      .catch((e) -> console.log(e); res.status(e.status || 500).json(e))
