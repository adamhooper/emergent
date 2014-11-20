module.exports =
  domains: [ 'www.linkedin.com' ]
  parse: (url, $, h) ->
    $article = $('div#article-container')

    source: 'LinkedIn'
    headline: $article.find('h1.article-title')
    byline: [ $('title').text().split(/\|/)[1].trim() ]
    body: $('#article-body>*')
