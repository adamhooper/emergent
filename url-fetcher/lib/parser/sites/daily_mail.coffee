module.exports =
  domains: [ 'www.dailymail.co.uk' ]
  parse: (url, $, h) ->
    $content = $('div#content')

    $content.find('.article-timestamp-label').remove() # makes parsing easier
    timeText = $('span.article-timestamp')
      .last() # if there's an "updated" timestamp after the "published" one, use it
      .text() # e.g., '22:27 GMT, 10 April 2014'
      .replace('BST', '+01:00')
      .replace('GMT', 'Z')

    source: 'Daily Mail'
    headline: $content.find('h1').text()
    byline: h.texts($('p.author-section .author'))
    publishedAt: h.moment(timeText, 'HH:mm ZZ, D MMMM YYYY')
    body: h.texts($content.find('ul.article-summary li, .article-text>p:not([class])'))
