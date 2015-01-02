module.exports =
  domains: [ 'www.lgbtqnation.com' ]
  parse: (url, $, h) ->
    $content = $('#content')
    $content.find('script, .wp-caption, p div').remove()

    source: 'LGBTQ Nation'
    headline: $content.find('h2.posttitle')
    byline: $content.find('.meta-post [rel=author]')
    body: $content.find('h6.cross-post, .entry p')
