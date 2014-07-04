module.exports =
  domains: [ 'www.bbc.com' ]
  parse: (url, $, h) ->
    $article = $('div.story-body').first()

    bylines = $article.find('span.byline-name').text().substr(3) # e.g., 'By William Kremer'

    timeText = h.texts($article.find('.story-date .date, .story-date .time')).join(' ')
    # e.g., "19 April 2014 10:25 ET"
    m = h.moment.tz(timeText, 'D MMMM YYYY HH:mm', 'America/New_York')

    source: 'BBC'
    headline: $article.find('h1').text()
    byline: [ bylines ]
    body: h.texts($article.children('p, span.cross-head'))
    publishedAt: m
