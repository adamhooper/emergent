module.exports =
  domains: [ 'www.igen.fr' ]
  parse: (url, $, h) ->
    source: 'www.igen.fr'
    headline: $('article h2').eq(0)
    byline: $('span.infos span.username')
    body: $('section.corps p')
