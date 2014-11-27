module.exports =
  version: 2
  domains: [ 'appleinsider.com' ]
  parse: (url, $, h) ->
    $article = $('.article')

    $h1 = $article.find('h1.art-head')
    $h1.remove()

    $byline = $article.find('p.byline')
    $byline.remove()
    $byline.find('.gray').remove() # the dateline

    $article.find('.article-img, .date-header, .gray, .small, .right').remove()

    # Cheerio doesn't convert <br> to \n like jQuery does. It also doesn't
    # let us simply insert newlines into the content.
    $article.find('br').replaceWith("LINEBREAK")

    source: 'AppleInsider'
    headline: $h1
    byline: $byline.find('*')
    body: $article.text().split(/LINEBREAK/g).map((s) -> s.trim()).filter((s) -> !!s)
