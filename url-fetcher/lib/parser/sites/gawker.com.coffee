module.exports =
  domains: [ 'gawker.com', 'valleywag.gawker.com', 'gizmodo.com' ]
  parse: (url, $, h) ->
    time = $('.column .publish-time').attr('data-publishtime')

    $body = $('.column .post-content')
    $body.find('aside').remove()

    source: $('meta[property="og:site_name"]').attr('content')
    byline: $('article .column .author')
    headline: $('h1.headline')
    publishedAt: new Date(+time)
    body: $body.find('p')
