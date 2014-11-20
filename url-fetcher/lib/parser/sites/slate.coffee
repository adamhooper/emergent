module.exports =
  domains: [ 'www.slate.com' ]
  parse: (url, $, h) ->
    # Remove image captions
    $('figure').remove()

    source: 'Slate'
    headline: $('h1.hed').text()
    byline: h.texts($('div.byline a, div.byline span'))
    body: h.texts($('section.content p'))
