module.exports =
  domains: [ 'arstechnica.com' ]
  parse: (url, $, h) ->
    $content = $('article .article-content')
    $content.find('figure').remove()

    source: 'Ars Technica'
    headline: $('article h1[itemprop=headline]')
    byline: $('a[rel=author]')
    body: $('.standalone-deck').add($content.children())
