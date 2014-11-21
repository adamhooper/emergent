module.exports =
  domains: [ 'www.slate.com' ]
  parse: (url, $, h) ->
    source: 'Slate'
    headline: $('h1.hed').first()
    byline: $('div.byline').find('a, span')
    body: $('section.content div.text')
