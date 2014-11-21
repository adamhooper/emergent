module.exports =
  version: 2
  domains: [ 'www.independent.co.uk' ]
  parse: (url, $, h) ->
    $body = $('#main').find('h3, .storyTop, .body')

    $body.find('.inline-image, div[id], script, h5').remove()

    source: 'The Independent'
    headline: $('h1')
    byline: $('div.author *, div.byline span.authorName')
    body: $body.find('p')
