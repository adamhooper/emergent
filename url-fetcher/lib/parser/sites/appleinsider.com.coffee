module.exports =
  domains: [ 'appleinsider.com' ]
  parse: (url, $, h) ->
    $article = $('.article')

    $h1 = $article.find('h1.art-head')
    $h1.remove()

    $date = $article.find('.date-header')
    $date.remove()

    $byline = $article.find('p.byline')
    $byline.remove()

    $article.find('.article-img').remove()

    # Cheerio doesn't convert <br> to \n like jQuery does. It also doesn't
    # let us simply insert newlines into the content.
    $article.find('br').replaceWith("LINEBREAK")

    source: 'AppleInsider'
    headline: $h1
    byline: $byline.find('*')
    body: $article.text().split(/LINEBREAK/g).map((s) -> s.trim()).filter((s) -> !!s)
