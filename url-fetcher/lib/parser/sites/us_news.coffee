module.exports =
  domains: [ 'www.usnews.com' ]
  parse: (url, $, h) ->
    $article = $('article#content')

    # Both sometimes has text like "[READ: NATO Ramp Up for Ukraine Continues Despite Geneva Peace Deal]"
    body = h.texts($article.find('div.skin-editable p'))
      .filter((s) -> !/^\[.*\]$/.test(s))

    source: 'U.S. News'
    headline: $article.find('h1.h-biggest').text()
    byline: h.texts($article.find('a[rel=author]'))
    body: body
