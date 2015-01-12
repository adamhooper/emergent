module.exports =
  version: 3
  domains: [ 'dailycaller.com' ]
  parse: (url, $, h) ->
    $authors = $('.dateline [rel=author], .author-box .name')

    $body = $('.article-content')
    $body.find('.wp-caption').remove()

    source: 'The Daily Caller'
    headline: $('#single h1, .full-page-article h1')
    byline: $authors
    body: $body.find('p')
