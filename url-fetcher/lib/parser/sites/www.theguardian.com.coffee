module.exports =
  domains: [ 'www.theguardian.com' ]
  parse: (url, $, h) ->
    publishedAt = if (timeText = $('span.timestamp').text())
      # Blog post
      # e.g., 'Wednesday 9 April 2014 15.45 BST'
      timeText = timeText
        .replace('BST', '+01:00')
        .replace('GMT', 'Z')
      h.moment(timeText, 'dddd D MMMM YYYY H.mm Z')
    else if (timeText = $('time[itemprop=datePublished]').attr('datetime'))
      # News article
      # e.g., '2014-07-04T16:22BST'
      timeText = timeText
        .replace('BST', '+01:00')
        .replace('GMT', 'Z')
      new Date(timeText)
    else
      null

    source: 'The Guardian'
    headline: $('div#article-header h1')
    byline: $('[itemprop=author]')
    publishedAt: publishedAt
    body: $('div#article-body-blocks p')
