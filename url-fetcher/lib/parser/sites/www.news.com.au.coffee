module.exports =
  domains: [ 'www.news.com.au' ]
  parse: (url, $, h) ->
    $body = $('.story-body')
    $body.find('.article-media, .module, script').remove()

    source: 'news.com.au'
    headline: $('h1')
    byline: $('.story-info li').filter('.byline, .source').find('cite')
    body: $body.find('p')
