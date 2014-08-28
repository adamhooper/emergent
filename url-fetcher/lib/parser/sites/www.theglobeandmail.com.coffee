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
    publishedAt: h.moment.tz($('meta[name="last-modified"]').attr('content'), 'YYYY-MM-DD HH:mm:ss', 'America/Toronto')
    body: $article.find('p')
