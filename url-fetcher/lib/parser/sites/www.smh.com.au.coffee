module.exports =
  domains: [ 'www.smh.com.au' ]
  parse: (url, $, h) ->
    $body = $('[itemprop=articleBody]')
    $body.find('script, [itemprop=video]').remove()

    source: 'The Sydney Morning Herald'
    headline: $('h1')
    byline: $('.authorName')
    body: $('[itemprop=articleBody] p')
