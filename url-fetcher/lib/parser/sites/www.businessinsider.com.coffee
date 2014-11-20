module.exports =
  domains: [ 'www.businessinsider.com' ]
  parse: (url, $, h) ->
    $('.image-container').remove()

    source: 'Business Insider'
    headline: $('h1').first().text()
    byline: h.texts($('[rel=author]'))
    body: h.texts($('.post-content p'))
