module.exports =
  version: 2
  domains: [ 'www.hiphophangover.com' ]
  parse: (url, $, h) ->
    $body = $('.item-page')
    $h2 = $body.find('h2')

    $h2.remove()

    $body.find('.spshare, .article-tools, .pager, #subscribe, script, style, ins').remove()

    source: 'Hip Hop Hangover [satire]'
    headline: $h2
    byline: []
    body: $body.children()
