module.exports =
  domains: [ '9to5mac.com' ]
  parse: (url, $, h) ->
    $content = $('article .article-content')
    $content.find('script, .related, .inlinead').remove()
    $end = $content.find('.sharedaddy, .social-bar, .related')
    $end.nextAll().remove()
    $end.remove()

    source: '9to5mac'
    headline: $('article h1')
    byline: $('article a[rel=author]')
    body: $content.children()
