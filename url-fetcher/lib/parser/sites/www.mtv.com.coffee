module.exports =
  domains: [ 'www.mtv.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    $byline = $article.find('.byline a[rel=author]')
    $article.find('#related_link, .photo, script, .author').remove()

    source: 'MTV News'
    headline: $('h1 span.headline')
    byline: $byline
    body: $article.find('.subhead, .entry-content p')
