module.exports =
  version: 2
  domains: [ 'gawker.com', 'valleywag.gawker.com', 'gizmodo.com' ]
  parse: (url, $, h) ->
    $body = $('.column .post-content')
    $body.find('aside').remove()

    source: $('meta[property="og:site_name"]').attr('content')
    byline: $('article .column .author')
    headline: $('h1.headline')
    body: $body.find('p')
