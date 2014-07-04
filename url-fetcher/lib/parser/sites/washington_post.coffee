module.exports =
  domains: [ 'www.washingtonpost.com' ]
  parse: (url, $, h) ->
    $article = $('article')

    # The time string in the article, e.g., "April 17", doesn't have enough
    # information. Let's use the URL. (We're missing 'Updated at'.)
    if (m = /\/(\d\d\d\d)\/(\d\d)\/(\d\d)/.exec(url))?
      m = h.moment.utc([ +m[1], +m[2] - 1, +m[3] ])

    source: 'The Washington Post'
    headline: $('h1').text()
    byline: h.texts($('span.pb-byline').children('a', 'span'))
    body: h.texts($article.find('p, h2')) # blockquotes contain <p>s
    publishedAt: m
