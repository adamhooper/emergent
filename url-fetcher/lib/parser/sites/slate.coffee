module.exports =
  domains: [ 'www.slate.com' ]
  parse: (url, $, h) ->
    # Remove image captions
    $('figure').remove()

    source: 'Slate'
    headline: $('h1.hed').text()
    byline: h.texts($('div.byline a, div.byline span'))
    publishedAt: h.moment.tz($('div.pub-date').text(), 'MMMM D YYYY h:mm A', 'America/New_York')
    body: h.texts($('section.content p'))
