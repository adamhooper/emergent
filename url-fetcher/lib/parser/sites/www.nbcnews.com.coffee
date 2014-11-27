module.exports =
  version: 2
  domains: [ 'www.nbcnews.com' ]
  parse: (url, $, h) ->
    $body = $('.stack-l-story')

    byline = $('h1.stack-heading-talent, h3.stack-heading-talent, h5').text().trim()
      .split(/\s*(—|,\s|,?\sand\s)\s*/g)
      .map((s) -> s.trim())
      .filter((s) -> s not in ['', '—', ',', 'and'])

    $('aside, .aside').remove()

    source: 'NBC News'
    byline: byline
    headline: $('h1.stack-heading')
    body: $body.find('p, figcaption, .figcaption')
