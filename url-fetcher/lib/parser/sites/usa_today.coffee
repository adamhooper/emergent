module.exports =
  domains: [ 'www.usatoday.com' ]
  parse: (url, $, h) ->
    $article = $('article.story')
    $metabar = $article.find('div[itemprop=author]')
    $bylines = $metabar.find('span[itemprop=name]') # e.g., "Oren Dorell, USA TODAY"

    timeText = $metabar.find('span.asset-metabar-time').text() # e.g., "7:49 p.m. EDT April 17, 2014"
    # Moment can't parse the 'EDT' properly.
    if (m = /^(\d\d?):(\d\d) ([ap])\.m\. ([A-Z][A-Z][A-Z]) (\w+) (\d\d?), (\d\d\d\d)$/.exec(timeText))?
      # To parse the 'April' part, we rewrite the date in a format moment will understand
      s = "#{m[7]} #{m[5]} #{m[6]} #{m[1]} #{m[2]} #{m[3]}m" # e.g., "2014 April 17 7:49 pm"
      m = h.moment.tz(s, 'YYYY MMMM D h:mm a', m[4])

    source: 'USA Today'
    headline: $article.find('h1').text()
    byline: h.texts($bylines).map((s) -> s.split(/,/)[0])
    publishedAt: m
    body: h.texts($article.find('div[itemprop=articleBody]>p'))
