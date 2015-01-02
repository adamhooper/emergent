module.exports =
  version: 2
  domains: [ 'freebeacon.com' ]
  parse: (url, $, h) ->
    $byline = $('[rel=author]')

    $body = $('.entry-content')
    $body.find('#feature-image').remove()
    $body.find('.author').parent().remove()

    source: 'The Washington Free Beacon'
    byline: $byline
    headline: $('h2.entry-title')
    body: $('.subheadline, .entry-content p')
