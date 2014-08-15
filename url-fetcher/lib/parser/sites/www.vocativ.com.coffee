module.exports =
  domains: [ 'www.vocativ.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    $posted = $article.find('.header-byline .posted .detail')
    # e.g. "07/25/14 10:53 EDT"
    publishedAt = if (m = /^(.*) (\w{3})$/.exec($posted.text()))?
      h.moment.tz(m[1], 'MM/DD/YY HH:mm', m[2])
    else
      null

    source: 'Vocativ'
    headline: $article.find('header h1').text()
    byline: h.texts($article.find('a[rel=author]'))
    publishedAt: publishedAt
    body: h.texts($article.find('.article-content>*:not(div, script)'))
