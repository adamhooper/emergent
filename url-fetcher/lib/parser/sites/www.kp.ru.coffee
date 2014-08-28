module.exports =
  domains: [ 'www.kp.ru' ]
  parse: (url, $, h) ->
    $h1 = $('h1.txt')
    $h1.children().remove()

    source: 'kp.ru'
    headline: $h1.text()
    body: h.texts($('#hypercontext').children('p'))
