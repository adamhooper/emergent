module.exports =
  version: 2
  domains: [ 'nationalreport.net' ]
  parse: (url, $, h) ->
    $body = $('.entry-content')
    $body.find('[id]').remove()

    source: 'National Report [satire]'
    byline: $('.entry-author h3')
    headline: $('h1.entry-title')
    body: $body.find('p, h3, li')
