validator = require('validator')

# A news story found online, at a URL.
#
# An Article may belong to multiple Stories, but usually it will belong to
# just one.
module.exports =
  identity: 'article'

  types:
    url: (s) -> validator.isURL(s, protocols: [ 'http', 'https' ], require_tld: true, require_protocol: true)

  attributes:
    url:
      type: 'string'
      url: true
      required: true

    createdBy:
      type: 'email'
      required: true

    updatedBy:
      type: 'email'
      required: true

    httpResponse:
      type: 'text'

    headline:
      type: 'text'

    body:
      type: 'text'

    stories:
      collection: 'story'
      via: 'articles'
