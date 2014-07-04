module.exports =
  domains: [ 'blogs.ft.com' ]
  parse: (url, $, h) ->
    # Half the timestamp comes from the article; the other from the URL
    publishedAt = null
    timeText = $('.entry-date').text() # e.g., Apr 11 17:43
    if (m = /\/(\d\d\d\d)\//.exec(url))?
      timeText = "#{m[1]} #{timeText}" # e.g., 2014 Apr 11 17:43
      publishedAt = h.moment.tz(timeText, 'YYYY MMM D HH:mm', 'America/New_York')

    source: 'Financial Times blogs'
    headline: $('h2.entry-title').text().trim()
    byline: h.texts($('.entry-meta [rel=author]'))
    publishedAt: publishedAt
    body: h.texts($('.entry-content p'))
