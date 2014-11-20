module.exports =
  domains: [ 'www.nydailynews.com' ]
  parse: (url, $, h) ->
    source: 'New York Daily News'
    headline: $('h1')
    byline: $('[rel=author]')
    body: $('#a-subheader, article p')
