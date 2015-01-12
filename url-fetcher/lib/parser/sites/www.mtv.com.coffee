module.exports =
  version: 2
  domains: [ 'www.mtv.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    $byline = $article.find('.byline a[rel=author]')
    $article.find('#related_link, .photo, script, .author').remove()

    source: 'MTV News'
    headline: $('h1 span.headline, span.headline h1')
    byline: $byline
    body: $article.find('.subhead, .entry-content p')
