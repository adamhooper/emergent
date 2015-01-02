module.exports =
  domains: [ 'dailycurrant.com', 'www.dailycurrant.com' ]
  parse: (url, $, h) ->
    $post = $('div.post')

    source: 'The Daily Currant'
    headline: $post.find('h2')
    byline: []
    body: $post.find('.entry p')
