module.exports =
  domains: [ 'www.express.co.uk' ]
  parse: (url, $, h) ->
    $article = $('article')
    $article.find('.related-articles').remove()

    source: 'Express'
    headline: $article.find('h1')
    byline: $article.find('[itemprop=author]')
    body: $article.find('header h3, section.text-description>*')
