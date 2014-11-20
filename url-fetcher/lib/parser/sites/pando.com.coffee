module.exports =
  version: 2
  domains: [ 'pando.com' ]
  parse: (url, $, h) ->
    $article = $('.post-content')
    $byline = $article.find('.byline').remove()
    $end = $article.find('.share_widgets')
    $end.nextAll().remove()
    $end.remove()

    source: 'Pando'
    headline: $('h1')
    byline: $byline.find('[rel=author]')
    body: $article.children()
