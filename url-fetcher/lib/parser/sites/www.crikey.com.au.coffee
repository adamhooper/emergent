module.exports =
  domains: [ 'www.crikey.com.au' ]
  parse: (url, $, h) ->
    $article = $('#content')

    source: 'Crikey'
    headline: $article.find('h2.entry-title')
    byline: $article.find('.entry-meta.author')
    body: $article.find('#post-excerpt, #post-content').find('p')
