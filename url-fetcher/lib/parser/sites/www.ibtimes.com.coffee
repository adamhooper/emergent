module.exports =
  domains: [ 'www.ibtimes.com' ]
  parse: (url, $, h) ->
    source: 'International Business Times US'
    headline: $('h1').text()
    byline: $('[rel=author]')
    publishedAt: new Date($('meta[name="DC.date.issued"]').attr('content'))
    body: $('.article-content p')
