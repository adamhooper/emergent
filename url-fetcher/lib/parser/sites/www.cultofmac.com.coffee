module.exports =
  domains: [ 'www.cultofmac.com' ]
  parse: (url, $, h) ->
    $article = $('#main-content>.post')
    $meta = $article.find('.post-meta')
    $authors = $meta.find('[rel=author]')
    $article.find('script, div, p.comments-link').remove()

    source: 'Cult of Mac'
    headline: $article.find('h2').text()
    byline: h.texts($authors)
    publishedAt: new Date($('meta[property="og:updated_time"]').attr('content'))
    body: h.texts($article.find('p'))
