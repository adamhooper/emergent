module.exports =
  domains: [ 'www.vocativ.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    source: 'Vocativ'
    headline: $article.find('header h1')
    byline: $article.find('a[rel=author]')
    body: $article.find('.article-content>*:not(div, script)')
