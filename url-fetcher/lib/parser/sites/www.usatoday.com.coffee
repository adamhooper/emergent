module.exports =
  domains: [ 'www.usatoday.com' ]
  parse: (url, $, h) ->
    $article = $('article.story, div[itemprop=articleBody]').eq(0)
    $bylines = $('div[itemprop=author] span[itemprop=name]') # e.g., "Oren Dorell, USA TODAY"

    source: 'USA Today'
    headline: $('h1[itemprop=headline]').text()
    byline: h.texts($bylines).map((s) -> s.split(/,/)[0])
    publishedAt: h.moment.tz($('meta[itemprop=dateModified]').attr('content'), 'America/New_York')
    body: h.texts($article.find('div[itemprop=articleBody]>p'))
