module.exports =
  domains: [ 'www.engadget.com' ]
  parse: (url, $, h) ->
    $body = $('#body')
    $body.find('.read-more, .promoted, .post-meta + *').remove()

    source: 'Engadget'
    headline: $('h1[itemprop=headline]')
    byline: $('p.byline [itemprop=author]')
    body: $body.find('p')
