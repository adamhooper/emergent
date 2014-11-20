module.exports =
  domains: [ 'knowmore.washingtonpost.com' ]
  parse: (url, $, h) ->
    $h6 = $('.post-full h6')
    $authors = $h6.find('[rel~=author]')
    $authors.remove()

    source: 'Know More'
    headline: $('h1').text()
    byline: h.texts($authors)
    body: h.texts($('.the-content>*'))
