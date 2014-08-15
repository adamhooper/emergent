module.exports =
  domains: [ 'www.abc.net.au' ]
  parse: (url, $, h) ->
    $article = $('.article')
    $headline = $article.find('h1').remove()
    $byline = $article.find('.byline').remove()
    $article.find('p.published, p.topics').remove()

    source: 'abc.net.au'
    headline: $headline.text()
    byline: h.texts($byline.find('a, span'))
    publishedAt: new Date($('meta[property="og:updated_time"]').attr('content'))
    body: h.texts($article.children().filter(':not(div)'))
