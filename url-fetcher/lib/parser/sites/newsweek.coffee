module.exports =
  version: 2
  domains: [ 'www.newsweek.com' ]
  parse: (url, $, h) ->
    $article = $('article.full-article')

    timeText = $article.find('[itemprop=datePublished]')
      .text()        # "Filed: ..."
      .substr(6)     # e.g., "4/11/14 at 7:17 PM"
      .trim()

    source: 'Newsweek'
    headline: $article.find('h1').text()
    byline: h.texts($article.find('[itemprop=author] [itemprop=name]'))
    publishedAt: h.moment.tz(timeText, 'M/DD/YY [at] hh:mm A', 'America/New_York')
    body: h.texts($article.find('p')) # but this is locked, so we get nothing.
