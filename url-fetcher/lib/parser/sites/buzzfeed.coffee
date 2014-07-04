module.exports =
  domains: [ 'www.buzzfeed.com' ]
  parse: (url, $, h) ->
    $article = $('article')
    $header = $article.find('header')
    $userInfo = $header.find('div.user-info-info')
    $body = $article.find('div[data-print=body]')

    # BuzzFeed has some wonky set of "superlist" tags that include numbers
    # in front of all paragraphs. So silly.
    $body.find('span.buzz_superlist_number_inline').remove()

    # And it puts links at the bottom of the article that bear an uncanny
    # resemblance to the rest of the article.
    $body.find('div.sub_buzz_link').remove()

    source: 'BuzzFeed'
    headline: $('h1#post-title').text()
    byline: h.texts($userInfo.find('a[rel=author]'))
    publishedAt: new Date($userInfo.find('span.ago time').attr('datetime'))
    body: h.texts($body.find('h2, p:not(.print)'))
