module.exports =
  domains: [ 'www.foxnews.com' ]
  parse: (url, $, h) ->
    $body = $('[itemprop=articleBody]')

    $body.find('div').remove()

    source: 'Fox News'
    headline: $('h1[itemprop=headline]')
    byline: $('.article-info [itemprop=name]')
    body: $body.children()
