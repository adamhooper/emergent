module.exports =
  domains: [ 'www.france24.com' ]
  parse: (url, $, h) ->
    $article = $('article.article-long')
    config = $('script.tc-config-vars').text()

    publishedAt = null
    if (m1 = /tc_vars\["aef_dpubli"\] = '(.*)'/.exec(config))? && (m2 = /tc_vars\["aef_hpubli"\] = '(.*)'/.exec(config))?
      publishedAt = h.moment.tz(m1[1] + m2[1], 'YYYY-MM-DDHH:mm', 'Europe/Paris')

    source: 'France 24'
    headline: $('h1.title').text()
    byline: h.texts($article.find('header p.author>*:first-child'))
    publishedAt: publishedAt
    body: h.texts($article.find('.bd>*'))
