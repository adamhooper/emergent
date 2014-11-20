module.exports =
  domains: [ 'www.businessinsider.in' ]
  parse: (url, $, h) ->
    $article = $('article')
    $article.find('.image').remove()

    source: 'Business Insider India'
    headline: $('h1')
    byline: $('.ByLine .Name')
    body: $article.find('.Normal p')
