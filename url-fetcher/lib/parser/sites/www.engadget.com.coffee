module.exports =
  domains: [ 'www.engadget.com' ]
  parse: (url, $, h) ->
    # Time format changed: what once worked no longer does
    publishedAtString = $('p.byline span.timeago').attr('datetime')
    publishedAt = new Date(publishedAtString)
    if isNaN(publishedAt.valueOf())
      publishedAt = h.moment.tz(publishedAtString, 'MMMM Do YYYY [at] h:mm a', 'America/New_York')

    $body = $('#body')
    $body.find('.read-more, .promoted, .post-meta + *').remove()

    source: 'Engadget'
    headline: $('h1[itemprop=headline]').text()
    byline: h.texts($('p.byline [itemprop=author]'))
    publishedAt: publishedAt
    body: $body.find('p')
