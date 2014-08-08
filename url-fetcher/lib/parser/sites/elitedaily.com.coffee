module.exports =
  domains: [ 'elitedaily.com' ]
  parse: (url, $, h) ->
    source: 'Elite Daily'
    headline: $('header h1').text()
    byline: h.texts($('[rel=author]'))
    publishedAt: new Date($('.post-date time').attr('datetime'))
    body: h.texts($('article.inPost .entry-content>*'))
