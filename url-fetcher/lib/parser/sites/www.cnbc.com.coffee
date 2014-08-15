module.exports =
  domains: [ 'www.cnbc.com' ]
  parse: (url, $, h) ->
    # remove "read more" links
    $body = $('[itemprop=articleBody]')
    $body.find('.label-read-more').closest('p').remove()
    $body.find('.twitter-tweet').remove()

    source: 'CNBC'
    headline: $('h1').text()
    byline: h.texts($('[rel=author]'))
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content'))
    body: h.texts($body.children())
