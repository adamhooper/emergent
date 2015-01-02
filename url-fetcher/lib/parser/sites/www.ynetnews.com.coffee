module.exports =
  domains: [ 'www.ynetnews.com' ]
  parse: (url, $, h) ->
    $body = $('.text16g, #article_content p')
    $body.find('img').parent().remove()

    source: 'Ynetnews'
    headline: $('h1')
    byline: $('span.text14').eq(0)
    body: $body
