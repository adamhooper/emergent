module.exports =
  domains: [ 'www.independent.co.uk' ]
  parse: (url, $, h) ->
    timeText = $('p.dateline').text()                 # e.g., 'Sunday 20 April 2014'
    timeText = timeText.substr(timeText.indexOf(' ')) # 20 April 2014

    source: 'The Independent'
    headline: $('h1').text().trim()
    byline: h.texts($('div.author *'))
    publishedAt: h.moment.utc(timeText, 'D MMMM YYYY')
    body: h.texts($('#main p'))
