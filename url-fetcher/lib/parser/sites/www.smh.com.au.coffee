module.exports =
  domains: [ 'www.smh.com.au' ]
  parse: (url, $, h) ->
    re = /effectiveDate: '(\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ)'/

    publishedAt = null
    $('script').each ->
      code = $(@).text()
      if (m = re.exec(code))
        publishedAt = new Date(m[1])

    $body = $('[itemprop=articleBody]')
    $body.find('script, [itemprop=video]').remove()

    source: 'The Sydney Morning Herald'
    headline: $('h1').text()
    byline: h.texts($('.authorName'))
    publishedAt: publishedAt
    body: h.texts($('[itemprop=articleBody] p'))
