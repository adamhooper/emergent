module.exports =
  domains: [ 'mashable.com' ]
  parse: (url, $, h) ->
    $article = $('article.full')

    # Haven't seen multiple authors, but this ought to cover it
    bylines = h.texts($article.find('.author_name'))
      .join(', ')
      .replace(/^By /g, '')
      .replace(' and ', ', ')
      .split(/\s*,\s*/)

    # Remove inner links, as they may change over time
    $article.find('div.see-also').remove()

    source: 'Mashable'
    headline: $article.find('h1').text()
    byline: bylines
    body: h.texts($article.find('p'))
