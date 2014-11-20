module.exports =
  domains: [ 'www.macrumors.com' ]
  parse: (url, $, h) ->
    $byline = $('.article .byline')
    [ dateString, byline ] = $byline.text().split(' by ')

    $content = $('.article .content')
    $content.find('img').remove() # Cheerio might pick up the alt
    $content.find('br').replaceWith('LINEBREAK')
    body = $content.text()
      .trim()
      .replace(/\s*LINEBREAK\s*/g, '\n')
      .split(/\n\n+/g)

    source: 'MacRumors'
    headline: $('h1.title')
    byline: byline.split(/\s*,\s*/)
    body: body
