module.exports =
  domains: [ 'bgr.com' ]
  parse: (url, $, h) ->
    $content = $('.article-content .text-column')
    $content.find('strong').remove() # "DON'T MISS" ... might be dynamic content?

    source: 'BGR'
    headline: $('h1.entry-title')
    byline: $('a[rel=author]')
    body: $content.children()
