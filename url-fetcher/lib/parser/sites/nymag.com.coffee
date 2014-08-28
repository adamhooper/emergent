module.exports =
  domains: [ 'nymag.com' ]
  parse: (url, $, h) ->
    source: 'NYMag'
    headline: $('h1')
    byline: $('.metaAuthor cite')
    publishedAt: $('.metaTime [itemprop=datePublished]').attr('content')
    body: $('div.entryText p')
