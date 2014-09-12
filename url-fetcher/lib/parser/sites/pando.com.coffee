module.exports =
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
    publishedAt: new Date($('meta[property="article:modified_time"]').attr('content'))
    body: $article.children()
