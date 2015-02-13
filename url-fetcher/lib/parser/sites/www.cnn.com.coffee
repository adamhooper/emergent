module.exports =
  version: 3
  domains: [ 'www.cnn.com' ]
  parse: (url, $, h) ->
    # e.g., "By Chief Washington Correspondent Jake Tapper, Nick Paton Walsh and Sherisse Pham, CNN"
    bylines = $('.cnnByline').text()
      .substr(3)
      .replace(/Chief \w+ Correspondent /g, '')
      .split(/\s*,\s+|\s+and\s+/g)
      .filter((s) -> s != 'CNN')
      .filter((s) -> s.length)

    if bylines.length == 0
      bylines = $('.metadata__byline__author a')

    source: 'CNN'
    headline: $('.cnn_storyarea h1, h2.pg-headline').text()
    byline: bylines
    body: h.texts($('.cnn_strycntntlft p, .zn-body p'))
