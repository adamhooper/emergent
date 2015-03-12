module.exports =
  domains: [ 'www.macrumors.com' ]
  parse: (url, $, h) ->
    $byline = $('.article .byline').eq(0)
    [ dateString, byline ] = $byline.text().split(' by ')

    $content = $('.article #content .body')
    if $content.length == 0
      $content = $('.article .content')
    $content.find('img').remove() # Cheerio might pick up the alt
    $content.find('.linkback').remove()
    $content.find('br').replaceWith('LINEBREAK')
    body = $content.text()
      .trim()
      .replace(/\s*LINEBREAK\s*/g, '\n')
      .split(/\n\n+/g)
      .filter((s) -> s.length)

    source: 'MacRumors'
    headline: $('h1.title, h1.header-title')
    byline: byline.split(/\s*,\s*/)
    body: body
