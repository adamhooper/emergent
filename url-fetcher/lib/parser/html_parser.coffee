cheerio = require('cheerio')
moment = require('moment-timezone')

# Joins the text of all elements with the given join string
#
# For instance,
#
#   joinTexts($('<ul><li>foo</li><li>bar</li></ul>').children(), "\n")
#
# Will return:
#
#   [ 'foo', 'bar' ]
texts = ($, $els, s) -> $els.map(-> $(@).text().trim()).toArray()

HtmlParser =
  parse: (url, html, done) ->
    if /^https?:\/\/www\.npr\.org\//.test(url)
      $ = cheerio.load(html, normalizeWhitespace: true)
      $article = $('article').first()

      ret = {}

      ret.source = 'NPR'
      ret.headline = $article.find('h1').text()
      $byline = $article.find('p.byline').first().children('a', 'span')
      ret.byline = texts($, $byline).join(', ')
      $body = $article.children().children('p')
      ret.body = texts($, $body).join("\n\n")

      timeText = $article.find('time').text() # e.g., "April 18, 2014 3:49 PM ET"
      m = moment.tz(timeText, 'MMMM D, YYYY h:mm A', 'America/New_York')
      ret.publishedAt = m.toDate()

      done(null, ret)

    else if /^https?:\/\/www\.bbc\.com\/news\//.test(url)
      $ = cheerio.load(html, normalizeWhitespace: true)
      $article = $('div.story-body').first()

      ret = {}

      ret.source = 'BBC'
      ret.headline = $article.find('h1').text()
      ret.byline = $article.find('span.byline-name').text().substr(3) # e.g., "By William Kremer"
      $body = $article.children('p, span.cross-head')
      ret.body = texts($, $body).join("\n\n")

      timeText = texts($, $article.find('.story-date .date, .story-date .time')).join(' ')
      # e.g., "19 April 2014 10:25 ET"
      m = moment.tz(timeText, 'D MMMM YYYY HH:mm', 'America/New_York')
      ret.publishedAt = m.toDate()

      done(null, ret)

module.exports = HtmlParser
