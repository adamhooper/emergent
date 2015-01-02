module.exports =
  version: 2
  domains: [ 'www.thedailybeast.com' ]
  parse: (url, $, h) ->
    $body = $('.dek, section.content-body p')
    $body.find('br').replaceWith('LINEBREAK')
    bodyArrays = h.texts($body).map((s) -> s.split(/LINEBREAK/))
    body = [].concat.apply([], bodyArrays)
      .map((s) -> s.trim())
      .filter((s) -> s.length)

    source: 'The Daily Beast'
    headline: $('h1[itemprop=name]')
    byline: $('a.more-by-author')
    body: body
