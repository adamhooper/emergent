module.exports =
  version: 2
  domains: [ 'www.mirror.co.uk' ]
  parse: (url, $, h) ->
    source: 'mirror.co.uk'
    headline: $('h1')
    byline: $('[rel=author]')
    body: $('.lead-text, .body>*')
