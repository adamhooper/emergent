module.exports =
  domains: [ 'techcrunch.com' ]
  parse: (url, $, h) ->
    $content = $('.article-entry')
    $content.find('img, script').remove()

    source: 'TechCrunch'
    headline: $('.article-header h1')
    byline: $('a[rel=author]')
    body: $content.children()
