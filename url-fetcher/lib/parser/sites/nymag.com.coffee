module.exports =
  domains: [ 'nymag.com' ]
  parse: (url, $, h) ->
    $headline = $('h1[itemprop=headline]')
    if $headline.length == 0
      $headline = $('h1')

    byline = $('meta[name=author]').attr('content')
    if byline
      byline = [ byline ]
    else
      byline = $('[rel=author]')

    $article = $('div.entryText, div[itemprop=articleBody]').eq(0)

    source: 'NYMag'
    headline: $headline
    byline: byline
    body: $article.find('p')
