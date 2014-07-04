module.exports =
  domains: [ 'www.businessinsider.in' ]
  parse: (url, $, h) ->
    timeText = $('.Date script').html() # document.write(formatArtDate('...'))
      .replace(/^.*\('(.*)'\).*$/, '$1') # e.g., 'Apr 11, 2014, 08.29 PM IST'

    $article = $('article')
    $article.find('.image').remove()

    source: 'Business Insider India'
    headline: $('h1').text()
    byline: h.texts($('.ByLine .Name'))
    publishedAt: h.moment.tz(timeText, 'MMM D, YYYY, hh.mm A', 'Asia/Kolkata')
    body: h.texts($article.find('.Normal p'))
