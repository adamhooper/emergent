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

    publishedAt = $('meta[property="article:published_time"], .metaTime [itemprop=datePublished]').eq(0).attr('content')

    $article = $('div.entryText, div[itemprop=articleBody]').eq(0)

    source: 'NYMag'
    headline: $headline
    byline: byline
    publishedAt: publishedAt
    body: $article.find('p')
