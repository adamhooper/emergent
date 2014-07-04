cheerio = require('cheerio')
moment = require('moment-timezone')

# Returns the text of each element in the Cheerio object.
#
# For instance,
#
#   texts($, $('<ul><li>foo</li><li>bar</li></ul>').children())
#
# Will return:
#
#   [ 'foo', 'bar' ]
texts = ($, $els) -> $els.map(-> $(@).text().trim()).toArray()

HtmlParser =
  parse: (url, html, done) ->
    $ = cheerio.load(html, normalizeWhitespace: true)
    ret = {}

    if /^https?:\/\/www\.npr\.org\//.test(url)
      $article = $('article').first()

      ret.source = 'NPR'
      ret.headline = $article.find('h1').text()
      $byline = $article.find('p.byline').first().children('a', 'span')
      ret.byline = texts($, $byline).join(', ')
      $body = $article.children().children('p')
      ret.body = texts($, $body).join("\n\n")

      timeText = $article.find('time').text() # e.g., "April 18, 2014 3:49 PM ET"
      m = moment.tz(timeText, 'MMMM D, YYYY h:mm A', 'America/New_York')
      ret.publishedAt = m.toDate()
    else if /^https?:\/\/www\.bbc\.com\/news\//.test(url)
      $article = $('div.story-body').first()

      ret.source = 'BBC'
      ret.headline = $article.find('h1').text()
      ret.byline = $article.find('span.byline-name').text().substr(3) # e.g., "By William Kremer"
      $body = $article.children('p, span.cross-head')
      ret.body = texts($, $body).join("\n\n")

      timeText = texts($, $article.find('.story-date .date, .story-date .time')).join(' ')
      # e.g., "19 April 2014 10:25 ET"
      m = moment.tz(timeText, 'D MMMM YYYY HH:mm', 'America/New_York')
      ret.publishedAt = m.toDate()
    else if /^https?:\/\/www\.washingtonpost\.com\//.test(url)
      ret.source = 'The Washington Post'
      ret.headline = $('h1').text()
      ret.byline = texts($, $('span.pb-byline').children('a', 'span')).join(', ')
      $article = $('article')
      $content = $article.find('p, h2') # blockquotes contain ps
      ret.body = texts($, $content).join("\n\n")

      # The time string in the article, e.g., "April 17", doesn't have enough
      # information. Let's use the URL. (We're missing 'Updated at'.)
      if (m = /\/(\d\d\d\d)\/(\d\d)\/(\d\d)/.exec(url))?
        m = moment.utc([ +m[1], +m[2] - 1, +m[3] ])
        ret.publishedAt = m.toDate()

    done(null, ret)

module.exports = HtmlParser
