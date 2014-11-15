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

    timeText = $('span.article-timestamp')
      .last() # if there's an "updated" timestamp after the "published" one, use it
      .text() # e.g., '22:27 GMT, 10 April 2014'
      .replace('BST', '+01:00')
      .replace('GMT', 'Z')

    source: 'Daily Mail'
    headline: $content.find('h1')
    byline: $bylines.find('.author')
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content').substring(0, 24))
    body: $content.find('ul.article-summary li, .article-text p')
