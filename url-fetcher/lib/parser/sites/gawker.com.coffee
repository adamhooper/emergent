module.exports =
  domains: [ 'gawker.com' ]
  parse: (url, $, h) ->
    time = $('.column .publish-time').attr('data-publishtime')

    source: 'Gawker'
    byline: h.texts($('article .column .author'))
    headline: $('h1.headline').text()
    publishedAt: new Date(+time)
    body: h.texts($('.column .post-content>p'))
