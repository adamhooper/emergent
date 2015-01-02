module.exports =
  domains: [ 'empirenews.net' ]
  parse: (url, $, h) ->
    $entry = $('div.entry')
    $entry.find('.shareaholic-canvas').nextAll().remove()
    $entry.find('.shareaholic-canvas').remove()

    source: 'Empire News'
    headline: $('h1.entry-title')
    byline: $('a[rel=author]')
    body: $entry.find('p')
