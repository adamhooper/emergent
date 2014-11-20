module.exports =
  version: 2
  domains: [ 'dailycaller.com' ]
  parse: (url, $, h) ->
    $dateline = $('.dateline')
    $authors = $dateline.find('[rel=author]')

    $body = $('.article-content')
    $body.find('.wp-caption').remove()

    source: 'The Daily Caller'
    headline: $('#single h1')
    byline: $authors
    body: $body.find('p')
