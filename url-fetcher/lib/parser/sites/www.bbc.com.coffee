module.exports =
  version: 2
  domains: [ 'www.bbc.com' ]
  parse: (url, $, h) ->
    $article = $('div.story-body').first()

    bylines = $article.find('span.byline-name').text().substr(3) # e.g., 'By William Kremer'
    bylines = if bylines
      [ bylines ]
    else
      reporterText = $('p.reporters').text().trim() # Reporters: Foo, Bar and Baz
      reporterText = reporterText.substring(reporterText.indexOf(' ') + 1)
      reporterText.split(/\s*,\s*|\s*,? and\s*/)

    timeText = h.texts($article.find('.story-date .date, .story-date .time')).join(' ')
    # e.g., "19 April 2014 10:25 ET"
    m = if timeText
      h.moment.tz(timeText, 'D MMMM YYYY HH:mm', 'America/New_York')
    else
      timeText = $('[data-datetime]').last().attr('data-datetime')
      h.moment(timeText + 'Z')

    $body = if $article.children('p').length
      $article.children('p, span.cross-head')
    else
      $('.live-event-summary li, .description p, .commentary-title')

    source: 'BBC'
    headline: $('h1')
    byline: bylines
    body: $body
    publishedAt: m
