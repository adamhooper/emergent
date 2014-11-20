module.exports =
  version: 2
  domains: [ 'www.newsweek.com' ]
  parse: (url, $, h) ->
    $article = $('article.full-article')

    source: 'Newsweek'
    headline: $article.find('h1').text()
    byline: $article.find('[itemprop=author] [itemprop=name]')
    body: $article.find('p') # but this is locked, so we get nothing.
