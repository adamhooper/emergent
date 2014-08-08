module.exports =
  domains: [ 'austriantimes.at', 'www.austriantimes.at' ]
  parse: (url, $, h) ->
    $body = $('h1 + p')
    # Cheerio has trouble with newlines
    $body.find('br').replaceWith('XXXNEWLINE')
    body = $body.text()
      .split(/XXXNEWLINE/)
      .map((s) -> s.trim())
      .filter((s) -> !!s)

    source: 'Austrian Times'
    byline: $('.autor').text().trim().split(/\s*,\s*/)
    headline: $('h1').text()
    publishedAt: h.moment.tz($('.articledate').text(), 'DD. MM. YY. - HH:mm', 'Europe/Vienna')
    body: body
