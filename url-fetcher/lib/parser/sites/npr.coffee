module.exports =
  domains: [ 'www.npr.org' ]
  parse: (url, $, h) ->
    $article = $('article').first()

    timeText = $article.find('time').text() # e.g., "April 18, 2014 3:49 PM ET"
    m = h.moment.tz(timeText, 'MMMM D, YYYY h:mm A', 'America/New_York')

    source: 'NPR'
    headline: $article.find('h1').text()
    byline: h.texts($article.find('p.byline').first().children('a', 'span'))
    publishedAt: m
    body: h.texts($article.children().children('p'))
