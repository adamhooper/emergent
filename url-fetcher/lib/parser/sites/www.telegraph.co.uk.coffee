module.exports =
  domains: [ 'www.telegraph.co.uk' ]
  parse: (url, $, h) ->
    jsonText = $('meta[name=parsely-page]').attr('content')
    json = JSON.parse(jsonText)

    $body = $('[itemprop=articleBody]')
    $body.find('script, .related_links_inline').remove()

    source: 'The Telegraph'
    headline: json.title.trim()
    byline: json.authors
    body: $body.find('p')
