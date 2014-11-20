module.exports =
  version: 2
  domains: [ 'www.washingtonpost.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    source: 'The Washington Post'
    headline: $('h1').text()
    byline: h.texts($('span.pb-byline').children('a', 'span'))
    body: h.texts($article.find('p, h2')) # blockquotes contain <p>s
