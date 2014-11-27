module.exports =
  domains: [ 'msnbc.website', 'www.msnbc.website' ]
  parse: (url, $, h) ->
    $('.post-content p + div').remove() # remove ad

    source: 'msnbc.website [not a news website]'
    headline: $('h1.entry-title')
    byline: []
    body: $('.post-content p')
