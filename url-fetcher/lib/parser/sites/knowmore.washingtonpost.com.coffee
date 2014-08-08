module.exports =
  domains: [ 'knowmore.washingtonpost.com' ]
  parse: (url, $, h) ->
    $h6 = $('.post-full h6')
    $authors = $h6.find('[rel~=author]')
    $authors.remove()

    time = $h6.text().replace('|', '').trim()
    m = h.moment.tz(time, 'MMMM D [at] h:mm a', 'America/New_York')

    source: 'Know More'
    headline: $('h1').text()
    byline: h.texts($authors)
    publishedAt: m
    body: h.texts($('.the-content>*'))
