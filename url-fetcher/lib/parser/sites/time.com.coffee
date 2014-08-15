module.exports =
  domains: [ 'time.com' ]
  parse: (url, $, h) ->
    $article = $('article').eq(0)

    source: 'Time'
    headline: $article.find('h2').first().text()
    byline: h.texts($article.find('a[itemprop=author]'))
    publishedAt: new Date($article.find('.article-meta time').last().attr('datetime') + 'Z')
    body: h.texts($article.find('.article-body>h2, .article-body>.video-content>*:not(aside, iframe)'))
