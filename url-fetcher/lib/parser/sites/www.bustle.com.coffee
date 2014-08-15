module.exports =
  domains: [ 'www.bustle.com' ]
  parse: (url, $, h) ->
    # This one is weird. The article content is in a JavaScript object.
    $script = $('script').filter (i, el) ->
      text = $(el).text()
      /var BustleData/.test(text)

    script = $script.text()
    obj = if (m = /pageData = (\{.*\});/.exec(script))?
      JSON.parse(m[1]).article ? {}
    else
      {}

    $body = $('<p>' + obj.body)
    $body.find('.twitter-tweet, iframe').remove()

    source: 'Bustle'
    headline: obj.title
    byline: [ obj.author?.name || '' ]
    publishedAt: new Date(obj.updated_at)
    body: h.texts($body)
