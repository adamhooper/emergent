module.exports =
  version: 2
  domains: [ 'www.dailymail.co.uk' ]
  parse: (url, $, h) ->
    $content = $('div#content')
    $content.find('.article-timestamp-label').remove() # makes parsing easier
    $bylines = $content.find('p.author-section').remove()
    $content.find('p.byline-section').remove()
    $content.find('#articleIconLinksContainer').remove()

    $end = $content.find('#external-source-links, #taboola-below-main-column, #most-watched-videos-wrapper')
    $end.nextAll().remove()
    $end.remove()

    source: 'Daily Mail'
    headline: $content.find('h1')
    byline: $bylines.find('.author')
    body: $content.find('ul.article-summary li, .article-text p')
