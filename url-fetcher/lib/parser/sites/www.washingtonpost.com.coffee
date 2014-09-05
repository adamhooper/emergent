module.exports =
  version: 2
  domains: [ 'www.washingtonpost.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    # The time string in the article, e.g., "April 17", doesn't have enough
    # information. Let's use the URL.
    #
    # Problems:
    # * We're missing "updated at"
    # * We don't even know what time zone the date is in
    #
    # See https://github.com/craigsilverman/truthmaker/issues/43
    if (m = /\/(\d\d\d\d\/\d\d\/\d\d)/.exec(url))?
      m = h.moment.tz(m[1], 'YYYY/MM/DD', 'America/New_York')

    source: 'The Washington Post'
    headline: $('h1').text()
    byline: h.texts($('span.pb-byline').children('a', 'span'))
    body: h.texts($article.find('p, h2')) # blockquotes contain <p>s
    publishedAt: m
