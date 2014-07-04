module.exports =
  domains: [ 'www.usnews.com' ]
  parse: (url, $, h) ->
    $article = $('article#content')

    # e.g., 'Thu Apr 17 17:14:32 EDT 2014' -- yeah, totally wrong HTML5
    timeText = $article.find('header time[itemprop=datePublished]').attr('datetime')
    if (m = /^\w+ (.*) (\w\w\w) (\d\d\d\d)$/.exec(timeText))?
      m = h.moment.tz("#{m[3]} #{m[1]}", 'YYYY MMM D h:mm:ss', m[2])

    # Both sometimes has text like "[READ: NATO Ramp Up for Ukraine Continues Despite Geneva Peace Deal]"
    body = h.texts($article.find('div.skin-editable p'))
      .filter((s) -> !/^\[.*\]$/.test(s))

    source: 'U.S. News'
    headline: $article.find('h1.h-biggest').text()
    byline: h.texts($article.find('a[rel=author]'))
    publishedAt: m
    body: body
