module.exports =
  domains: [ 'www.jpost.com' ]
  parse: (url, $, h) ->
    $article = $('.mainarticle')
    $body = $article.find('.body')
    $body.children('script, div, br').remove()

    source: 'The Jerusalem Post'
    headline: $article.find('h1').text().trim()
    byline: h.texts($article.find('div.author>*')).map((s) -> s.replace(/^By /, ''))
    publishedAt: h.moment.tz($article.find('div.date').text(), 'MM/DD/YYYY HH:mm', 'Asia/Jerusalem')
    body: h.texts($body.children())
