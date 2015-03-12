module.exports =
  domains: [ 'www.bloomberg.com' ]
  parse: (url, $, h) ->
    $article = $('article').eq(0)
    $content = $article.find('.article-body')

    source: 'Bloomberg'
    byline: $article.find('a[rel=author]')
    headline: $article.find('h1[itemprop~=headline]')
    body: $content.children()
