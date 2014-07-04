module.exports =
  domains: [ 'www.theguardian.com' ]
  parse: (url, $, h) ->
    $header = $('div#article-header')

    timeText = $('.timestamp').text() # e.g., 'Wednesday 9 April 2014 15.45 BST'
      # BST 
      .replace('BST', '+01:00')
      .replace('GMT', 'Z')
    m = h.moment(timeText, 'dddd D MMMM YYYY H.mm Z')

    source: 'The Guardian'
    headline: $header.find('h1').text()
    byline: h.texts($('[itemprop=author]'))
    publishedAt: m
    body: h.texts($('div#article-body-blocks p'))
