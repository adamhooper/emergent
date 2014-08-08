module.exports =
  domains: [ 'macdailynews.com' ]
  parse: (url, $, h) ->
    $meta = $('h1 + .post-meta')
    $meta.find('*').remove()
    m = h.moment.tz($meta.text().trim(), 'dddd, MMMM D, YYYY[ ·  ]hh:mm a', 'America/New_York')

    $body = $('.post-content').children()
    $body.find('script').remove()

    source: 'MacDailyNews'
    headline: $('h1.post-title').text()
    publishedAt: m
    byline: [ '' ]
    body: h.texts($body)
