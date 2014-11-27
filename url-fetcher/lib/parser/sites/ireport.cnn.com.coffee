module.exports =
  domains: [ 'ireport.cnn.com' ]
  parse: (url, $, h) ->
    source: 'CNN iReport'
    headline: $('h2.story-title')
    byline: $('.byline a.ir-username-link')
    body: $('#producer-note-block p, #story-desc p')
