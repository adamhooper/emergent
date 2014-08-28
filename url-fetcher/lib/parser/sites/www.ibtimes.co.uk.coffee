module.exports =
  domains: [ 'www.ibtimes.co.uk' ]
  parse: (url, $, h) ->
    $article = $('article .article-text')
    $article.find('script, .imageBox').remove()

    source: 'International Business Times'
    headline: $('h1').text()
    byline: h.texts($('[rel=author]'))
    publishedAt: h.moment.tz($('[itemprop=datePublished]').text(), 'MMMM DD, YYYY HH:mm', 'Europe/London')
    body: h.texts($article.children())
