module.exports =
  domains: [ 'blogs.ft.com' ]
  parse: (url, $, h) ->
    source: 'Financial Times blogs'
    headline: $('h2.entry-title').text().trim()
    byline: h.texts($('.entry-meta [rel=author]'))
    body: h.texts($('.entry-content p'))
