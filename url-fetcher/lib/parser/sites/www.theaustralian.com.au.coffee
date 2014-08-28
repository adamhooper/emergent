module.exports =
  domains: [ 'www.theaustralian.com.au' ]
  parse: (url, $, h) ->
    $body = $('.story-body')
    $body.find('.article-media, script').remove()
    # Ugly hack because they inject Twitter <p> within a <p>
    $body.find('p p').each ->
      $parent = $(@).parent().closest('p')
      $parent.text($parent.text())

    source: 'The Australian'
    headline: $('h1.heading')
    byline: $('cite.author').text().trim().split(/, | and /)
    publishedAt: $('.date-and-time').attr('title')
    body: $body.find('p')
