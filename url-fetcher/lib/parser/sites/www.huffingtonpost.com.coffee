module.exports =
  domains: [ 'www.huffingtonpost.com', 'www.huffingtonpost.co.uk' ]
  parse: (url, $, h) ->
    $content = $('#mainentrycontent, .entry-content')
    $content.find('div.clear').nextAll().remove()
    $content.find('.hp-slideshow-wrapper, script, link, #liveblog_heading, #liveblog_container, #liveblog_footing').remove()

    byline = h.texts($('a[rel=author]'))
    if byline.length == 0
      byline = $('a.wire_author').text().split(/,| and /g).map((s) -> s.trim())

    updatedString = $('.updated time').attr('datetime')
    if !updatedString
      updatedString = $('span.updated[title]').attr('title')

    source: $('header .branding strong.title').text() || 'The Huffington Post'
    headline: $('h1')
    byline: byline
    publishedAt: new Date(updatedString)
    body: h.texts($content.find('p'))
