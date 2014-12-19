module.exports =
  version: 2
  domains: [ 'nymag.com' ]
  parse: (url, $, h) ->
    $headline = $('h1[itemprop=headline], h2.primary.first-page')
    if $headline.length == 0
      $headline = $('meta[property="og:title"]').attr('content')

    byline = $('meta[name=author]').attr('content')
    if byline
      byline = [ byline ]
    else
      byline = $('[rel=author], ul.byline a')

    $article = $('div.entryText, div[itemprop=articleBody], div#story').eq(0)

    source: 'NYMag'
    headline: $headline
    byline: byline
    body: $article.find('p')
