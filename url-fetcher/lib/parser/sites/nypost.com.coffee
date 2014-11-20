module.exports =
  domains: [ 'nypost.com' ]
  parse: (url, $, h) ->
    source: 'New York Post'
    headline: $('.article-header h1').text()
    byline: h.texts($('.article-header .byline>*'))
    body: h.texts($('.entry-content>p'))
