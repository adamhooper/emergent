module.exports =
  domains: [ 'www.npr.org' ]
  parse: (url, $, h) ->
    $article = $('article').first()

    source: 'NPR'
    headline: $article.find('h1')
    byline: $article.find('p.byline').first().children('a', 'span')
    body: $article.children().children('p')
