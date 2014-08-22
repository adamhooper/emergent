module.exports =
  domains: [ 'www.fastcompany.com' ]
  parse: (url, $, h) ->
    $article = $('article.full-view')

    source: 'Fast Company'
    headline: $('h1').text().trim()
    byline: h.texts($article.find('header [rel=author]'))
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content'))
    body: h.texts($article.find('.body p'))
