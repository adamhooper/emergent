module.exports =
  domains: [ 'www.crikey.com.au' ]
  parse: (url, $, h) ->
    $article = $('#content')

    source: 'Crikey'
    headline: $article.find('h2.entry-title').text()
    byline: h.texts($article.find('.entry-meta.author'))
    publishedAt: h.moment.tz($article.find('.entry-meta .date').text(), 'MMM DD, YYYY h:mmA', 'Australia/Melbourne')
    body: h.texts($article.find('#post-excerpt, #post-content').find('p'))
