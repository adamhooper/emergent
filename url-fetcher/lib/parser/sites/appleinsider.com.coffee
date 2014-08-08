module.exports =
  domains: [ 'appleinsider.com' ]
  parse: (url, $, h) ->
    $article = $('.article')

    $h1 = $article.find('h1.art-head')
    $h1.remove()

    $date = $article.find('.date-header')
    $date.remove()

    timeText = $date.text().trim()
    # e.g., "Monday, July 14, 2014, 02:51 pm PT (05:51 pm ET)"
    m = h.moment.tz(timeText, 'dddd, MMMM DD, YYYY, hh:mm a', 'America/Los_Angeles')

    $byline = $article.find('p.byline')
    $byline.remove()

    $article.find('.article-img').remove()

    # Cheerio doesn't convert <br> to \n like jQuery does. It also doesn't
    # let us simply insert newlines into the content.
    $article.find('br').replaceWith("LINEBREAK")

    source: 'AppleInsider'
    headline: $h1.text()
    publishedAt: m
    byline: h.texts($byline.find('*'))
    body: $article.text().split(/LINEBREAK/g).map((s) -> s.trim()).filter((s) -> !!s)
