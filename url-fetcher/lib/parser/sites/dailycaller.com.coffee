module.exports =
  domains: [ 'dailycaller.com' ]
  parse: (url, $, h) ->
    $dateline = $('.dateline')
    $authors = $dateline.find('[rel=author]')
    $dateline.find('*').remove() # so we can get at the date

    $body = $('.article-content')
    $body.find('.wp-caption').remove()

    source: 'The Daily Caller'
    headline: $('#single h1').text()
    byline: h.texts($authors)
    publishedAt: h.moment.tz($dateline.text().trim(), 'H:mm A  MM/DD/YYYY', 'America/New_York')
    body: h.texts($body.find('p'))
