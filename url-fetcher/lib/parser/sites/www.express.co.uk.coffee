module.exports =
  domains: [ 'www.express.co.uk' ]
  parse: (url, $, h) ->
    $article = $('article')
    $article.find('.related-articles').remove()

    source: 'Express'
    headline: $article.find('h1').text()
    byline: h.texts($article.find('[itemprop=author]'))
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content') + 'Z')
    body: h.texts($article.find('header h3, section.text-description>*'))
