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

    $body = if $article.children('p').length
      $article.children('p, span.cross-head')
    else
      $('.live-event-summary li, .description p, .commentary-title')

    source: 'BBC'
    headline: $('h1')
    byline: bylines
    body: $body
