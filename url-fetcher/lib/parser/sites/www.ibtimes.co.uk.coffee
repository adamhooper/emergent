module.exports =
  domains: [ 'www.ibtimes.co.uk' ]
  parse: (url, $, h) ->
    $article = $('article .article-text')
    $article.find('script, .imageBox').remove()

    source: 'International Business Times UK'
    headline: $('h1')
    byline: $('[rel=author]')
    body: $article.children()
