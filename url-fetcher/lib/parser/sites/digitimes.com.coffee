module.exports =
  domains: [ 'digitimes.com', 'www.digitimes.com' ]
  parse: (url, $, h) ->
    source: 'DigiTimes'
    headline: $('div.H1')
    byline: $('div.Author').text().split(',').slice(0, 1)
    body: $('p.P1, p.P2')
