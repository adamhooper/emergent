module.exports =
  index: (req, res) ->
    models.Url.findAllUnparsed({ attributes: [ 'url' ] }, raw: true)
      .then((urls) -> res.json(u.url for u in urls))
      .catch((e) -> res.status(e.status || 500).json(e))
