module.exports =
  domains: [ 'daringfireball.net' ]
  parse: (url, $, h) ->
    $article = $('.article')
    $h1 = $article.find('h1').remove()
    $article.find('.dateline').remove()
    $('#PreviousNext').remove()

    source: 'Daring Fireball'
    headline: $h1
    byline: [ 'John Gruber' ]
    body: $article.children()
