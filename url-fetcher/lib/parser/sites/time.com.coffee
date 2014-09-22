module.exports =
  version: 2
  domains: [ 'time.com' ]
  parse: (url, $, h) ->
    $article = $('article').eq(0)
    $body = $article.find('.article-body')

    source: 'Time'
    headline: $article.find('h2').first()
    byline: $article.find('a[itemprop=author]')
    publishedAt: h.moment.tz($article.find('.article-meta time').last().attr('datetime'), 'America/New_York')
    body: $body.find('h2, p').filter(':not(aside, iframe)')
