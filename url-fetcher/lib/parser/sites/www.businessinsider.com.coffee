module.exports =
  domains: [ 'www.businessinsider.com' ]
  parse: (url, $, h) ->
    $('.image-container').remove()

    $content = $('.post-content')
    $content.find('.image-container, .popular-video, .feed-footer').remove()

    source: 'Business Insider'
    headline: $('h1').first().text()
    byline: h.texts($('[rel=author]'))
    body: h.texts($content.find('p, li'))
