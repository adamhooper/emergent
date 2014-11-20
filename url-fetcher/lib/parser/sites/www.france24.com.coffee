module.exports =
  domains: [ 'www.france24.com' ]
  parse: (url, $, h) ->
    $article = $('article.article-long')
    config = $('script.tc-config-vars').text()

    source: 'France 24'
    headline: $('h1.title')
    byline: $article.find('header p.author>*:first-child')
    body: $article.find('.bd>*')
