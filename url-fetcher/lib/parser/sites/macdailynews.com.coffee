module.exports =
  domains: [ 'macdailynews.com' ]
  parse: (url, $, h) ->
    $body = $('.post-content').children()
    $body.find('script').remove()

    source: 'MacDailyNews'
    headline: $('h1.post-title')
    byline: [ '' ]
    body: $body
