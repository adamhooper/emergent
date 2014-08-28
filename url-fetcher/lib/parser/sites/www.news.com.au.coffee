module.exports =
  domains: [ 'www.news.com.au' ]
  parse: (url, $, h) ->
    $body = $('.story-body')
    $body.find('.article-media, .module, script').remove()

    source: 'news.com.au'
    headline: $('h1').text().trim()
    byline: h.texts($('.story-info li').filter('.byline, .source').find('cite'))
    publishedAt: new Date($('.story-info .date-and-time').attr('title'))
    body: h.texts($body.find('p'))
