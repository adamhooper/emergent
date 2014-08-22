module.exports =
  domains: [ 'www.dailydot.com' ]
  parse: (url, $, h) ->
    source: 'The Daily Dot'
    headline: $('h1').text()
    byline: h.texts($('p.byline .by-date').children(':not(time)'))
    publishedAt: new Date($('p.byline .by-date time').attr('datetime') + 'Z')
    body: h.texts($('.article-content p:not(.byline)'))
