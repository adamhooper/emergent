module.exports =
  version: 2
  domains: [ 'www.jpost.com' ]
  parse: (url, $, h) ->
    $article = $('.mainarticle, .article-box')

    # old site design
    $body = $article.find('.body')
    $body.children('script, div, br').remove()
    body = h.texts($body.children()).filter((x) -> x.trim().length)

    if !body.length
      # new site design, current at 2014-10-30
      $body = $article.find('.article-teaser-text, .article-text p')
      $body.find('br').replaceWith('LINEBREAK')
      bodyArrays = h.texts($body).map((s) -> s.split(/LINEBREAK/))
      body = [].concat.apply([], bodyArrays)
        .map((s) -> s.trim())
        .filter((s) -> s.length)

    source: 'The Jerusalem Post'
    headline: $article.find('h1, .article-title')
    byline: h.texts($article.find('div.author>*, [rel="Author"]')).map((s) -> s.replace(/^By /, ''))
    body: body
