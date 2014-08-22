module.exports =
  domains: [ 'www.huffingtonpost.com' ]
  parse: (url, $, h) ->
    $('#mainentrycontent div.clear').nextAll().remove()

    source: $('header .branding strong').text()
    headline: $('h1.title').text()
    byline: h.texts($('a[rel=author]'))
    publishedAt: new Date($('.updated time').attr('datetime'))
    body: h.texts($('#mainentrycontent p'))
