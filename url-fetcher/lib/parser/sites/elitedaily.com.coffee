module.exports =
  domains: [ 'elitedaily.com' ]
  parse: (url, $, h) ->
    source: 'Elite Daily'
    headline: $('header h1').text()
    byline: h.texts($('[rel=author]'))
    body: h.texts($('article.inPost .entry-content>*'))
