module.exports =
  version: 2
  domains: [ 'time.com' ]
  parse: (url, $, h) ->
    $article = $('article').eq(0)
    $body = $article.find('.article-body')

    source: 'Time'
    headline: $article.find('h2').first()
    byline: $article.find('a[itemprop=author]')
    body: $body.find('h2, p').filter(':not(aside, iframe)')
