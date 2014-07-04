module.exports =
  domains: [ 'nymag.com' ]
  parse: (url, $, h) ->
    source: 'NYMag'
    headline: $('h1').text()
    byline: h.texts($('.metaAuthor cite'))
    publishedAt: new Date($('.metaTime [itemprop=datePublished]').attr('content'))
    body: h.texts($('div.entryText p'))
