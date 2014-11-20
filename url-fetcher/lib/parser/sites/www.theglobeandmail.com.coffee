module.exports =
  domains: [ 'www.theglobeandmail.com' ]
  parse: (url, $, h) ->
    $h1 = $('h1')
    $h1.children().remove()

    $article = $('.entry-content')
    $article.find('.widget, .entry-related, .article__ontwitter').remove()

    source: 'The Globe and Mail'
    headline: $h1
    byline: $('.creditline')
    body: $article.find('p')
