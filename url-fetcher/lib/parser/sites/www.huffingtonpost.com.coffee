module.exports =
  domains: [ 'www.huffingtonpost.com', 'www.huffingtonpost.co.uk' ]
  parse: (url, $, h) ->
    $content = $('#mainentrycontent')
    $content.find('div.clear').nextAll().remove()
    $content.find('.hp-slideshow-wrapper, script, link, #liveblog_heading, #liveblog_container, #liveblog_footing').remove()

    source: $('header .branding strong.title').text()
    headline: $('h1.title').text()
    byline: h.texts($('a[rel=author]'))
    publishedAt: new Date($('.updated time').attr('datetime'))
    body: h.texts($content.find('p'))
