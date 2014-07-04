module.exports =
  domains: [ 'www.engadget.com' ]
  parse: (url, $, h) ->
    source: 'Engadget'
    headline: $('h1[itemprop=headline]').text()
    byline: h.texts($('p.byline [itemprop=author]'))
    publishedAt: new Date($('p.byline span.timeago').attr('datetime'))
    body: h.texts($('#body .copy p:not([class])'))
