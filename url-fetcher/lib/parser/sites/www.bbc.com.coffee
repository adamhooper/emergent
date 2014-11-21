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

    source = if $('div.the-papers.main-content-container').length
      'BBC The Papers'
    else
      'BBC'

    # Normal story
    $body = $article.children('p, span.cross-head')

    if !$body.length
      # Live event
      $body = $('.live-event-summary li, .description p, .commentary-title')
    if !$body.length
      # The Papers
      $body = $article.find('.caption span')

    source: source
    headline: $('h1')
    byline: bylines
    body: $body
