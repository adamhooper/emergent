module.exports =
  domains: [ 'www.wsj.com' ]
  parse: (url, $, h) ->
    $content = $('article [itemprop="articleBody"]')
    $bylineWrap = $('.byline-wrap')
    $content.find('.media-object, .byline-wrap, .textAd').remove()

    source: 'The Wall Street Journal'
    headline: $('h1[itemprop=headline]')
    byline: $bylineWrap.find('span[itemprop=name]')
    body: $('article h2.sub-head').add($content.children())
