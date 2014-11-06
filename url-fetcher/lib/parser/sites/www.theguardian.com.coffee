module.exports =
  version: 3
  domains: [ 'www.theguardian.com' ]
  parse: (url, $, h) ->
    if $('meta[property="og:type"]').attr('content') == 'video'
      source: 'The Guardian'
      headline: $('h1[itemprop=headline]')
      byline: [ $('p.byline').text().replace('Source: ', '') ]
      publishedAt: new Date($('time[itemprop="datePublished"]').attr('datetime'))
      body: $('.content__standfirst')
    else
      source: 'The Guardian'
      headline: $('div#article-header h1')
      byline: $('[itemprop=author]')
      publishedAt: new Date($('meta[property="article:modified_time"]').attr('content'))
      body: $('#article-header [itemprop=description], div#article-body-blocks p')
