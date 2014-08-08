module.exports =
  domains: [ 'nypost.com' ]
  parse: (url, $, h) ->
    source: 'New York Post'
    headline: $('.article-header h1').text()
    byline: h.texts($('.article-header .byline>*'))
    publishedAt: h.moment.tz($('.article-header .byline-date').text(), 'MMMM D, YYYY[ | ]hh:mma', 'America/New_York')
    body: h.texts($('.entry-content>p'))
