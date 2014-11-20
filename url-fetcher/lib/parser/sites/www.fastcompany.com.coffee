module.exports =
  domains: [ 'www.fastcompany.com' ]
  parse: (url, $, h) ->
    $article = $('article.full-view')

    source: 'Fast Company'
    headline: $('h1')
    byline: $article.find('header [rel=author]')
    body: $article.find('.body p')
