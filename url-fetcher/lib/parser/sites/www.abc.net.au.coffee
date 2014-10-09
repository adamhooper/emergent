module.exports =
  version: 2
  domains: [ 'www.abc.net.au' ]
  parse: (url, $, h) ->
    if /www.abc.net.au\/news\//.test(url)
      $article = $('.article')
      $headline = $article.find('h1').remove()
      $byline = $article.find('.byline').remove()
      $article.find('p.published, p.topics').remove()

      source: 'abc.net.au'
      headline: $headline
      byline: h.texts($byline.find('a, span'))
      publishedAt: new Date($('meta[property="og:updated_time"]').attr('content'))
      body: h.texts($article.children().filter(':not(div)'))
    else
      publishing = $('#main .publishing').text().split(/\sreported this story on\s/)
      $article = $('#article')
      $article.find('br').replaceWith('LINEBREAK')
      body = $article.text()
        .trim()
        .replace(/\s*LINEBREAK\s*/g, '\n')
        .split(/\n\n+/g)

      source: 'abc.net.au'
      headline: $('#main h1')
      byline: [ publishing[0] ]
      publishedAt: h.moment.tz(publishing[1], 'dddd, MMMM D, YYYY HH:mm:SS', 'Australia/Sydney')
      body: body
