module.exports =
  version: 2
  domains: [ 'www.cnn.com' ]
  parse: (url, $, h) ->
    # e.g., "By Chief Washington Correspondent Jake Tapper, Nick Paton Walsh and Sherisse Pham, CNN"
    bylines = $('.cnnByline').text()
      .substr(3)
      .replace(/Chief \w+ Correspondent /g, '')
      .split(/\s*,\s+|\s+and\s+/g)
      .filter((s) -> s != 'CNN')

    source: 'CNN'
    headline: $('.cnn_storyarea h1').text()
    byline: bylines
    body: h.texts($('.cnn_strycntntlft p'))
