module.exports =
  version: 4
  domains: [ 'www.theguardian.com' ]
  parse: (url, $, h) ->
    if $('meta[property="og:type"]').attr('content') == 'video'
      source: 'The Guardian'
      headline: $('h1[itemprop=headline]')
      byline: [ $('p.byline').text().replace('Source: ', '') ]
      body: $('.content__standfirst')
    else
      source: 'The Guardian'
      headline: $('h1[itemprop~=headline]')
      byline: $('p.byline [itemprop=author], .contributor-full [itemprop=author]')
      body: $('#article-header [itemprop=description], div#article-body-blocks p, [itemprop="articleBody"] p')
