module.exports =
  domains: [ 'www.theepochtimes.com' ]
  parse: (url, $, h) ->
    source: 'The Epoch Times'
    headline: $('h1')
    byline: $('[rel=author]')
    body: $('#artcontent p')
