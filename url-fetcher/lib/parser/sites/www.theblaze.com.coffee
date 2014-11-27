module.exports =
  domains: [ 'www.theblaze.com' ]
  parse: (url, $, h) ->
    $body = $('[itemprop=articleBody]')
    $body.find('script').remove()

    source: 'The Blaze'
    headline: $('h1[itemprop=headline]')
    byline: $('a[itemprop=author]')
    body: $body.find('p')
