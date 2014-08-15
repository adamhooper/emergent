module.exports =
  domains: [ 'www.linkedin.com' ]
  parse: (url, $, h) ->
    $article = $('div#article-container')
    publishedAt = null
    if (m = /(\d{14})[^/]+$/.exec(url))?
      publishedAt = h.moment.utc(m[1], 'YYYYMMDDHHmmss')

    source: 'LinkedIn'
    headline: $article.find('h1.article-title').text()
    byline: [ $('title').text().split(/\|/)[1].trim() ]
    publishedAt: publishedAt
    body: h.texts($('#article-body>*'))
