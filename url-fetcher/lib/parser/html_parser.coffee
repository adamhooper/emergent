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
    else if /^https?:\/\/www\.usatoday\.com\//.test(url)
      $article = $('article.story')
      ret.source = 'USA Today'
      ret.headline = $article.find('h1').text()
      $metabar = $article.find('div[itemprop=author]')
      $bylines = $metabar.find('span[itemprop=name]') # e.g., "Oren Dorell, USA TODAY"
      ret.byline = texts($, $bylines).map((s) -> s.split(/,/)[0]).join(', ')
      timeText = $metabar.find('span.asset-metabar-time').text() # e.g., "7:49 p.m. EDT April 17, 2014"
      # Moment can't parse the 'EDT' properly.
      if (m = /^(\d\d?):(\d\d) ([ap])\.m\. ([A-Z][A-Z][A-Z]) (\w+) (\d\d?), (\d\d\d\d)$/.exec(timeText))?
        # To parse the 'April' part, we rewrite the date in a format moment will understand
        s = "#{m[7]} #{m[5]} #{m[6]} #{m[1]} #{m[2]} #{m[3]}m" # e.g., "2014 April 17 7:49 pm"
        m = moment.tz(s, 'YYYY MMMM D h:mm a', m[4])
        ret.publishedAt = m.toDate()
      ret.body = texts($, $article.find('div[itemprop=articleBody]>p')).join("\n\n")
    else if /^https?:\/\/(?:www\.)?snopes\.com\//.test(url)
      $article = $('td.contentColumn')
      ret.source = 'Snopes'
      ret.headline = $article.find('h1').text()
      ret.byline = ''
      # Search for "Last updated:" in a <b> within a <font>. The next text node is the date.
      for b in $article.find('b')
        if b.children[0]?.data == 'Last updated:'
          timeText = b.parent.next?.data
          break
      if timeText?
        m = moment.tz(timeText, 'D MMMM YYYY', 'America/Los_Angeles')
        ret.publishedAt = m.toDate()
      # Parse the body. This is hard.
      lines = []
      thisLine = []
      endLine = ->
        s = thisLine.map((s) -> s.trim()).filter((s) -> s != '').join(' ')
        if s != ''
          lines.push(s)
        thisLine = []
      walk = (parent) ->
        for el in parent.children # walk the DOM: we need text nodes
          if el.type == 'text'
            thisLine.push(el.data)
          else if el.type == 'tag'
            if el.name == 'br'
              endLine()
            else if el.name == 'noindex' # MIXTURE / TRUE / FALSE lines
              lines.push(line) for line in texts($, $(el).find('td[valign=TOP]'))
            else if el.name == 'font'
              walk(el)
            else if el.name == 'div'
              endLine()
              walk(el)
              endLine()
            else if el.name == 'table'
              # do not parse. This is an ad.
            else
              thisLine.push($(el).text())
      walk($('.article_text')[0])
      endLine()
      lines.pop() # copyright
      lines.pop() # "last updated"
      $table = $('.article_text').next().next()
      lines.push($table.text().trim())
      $sources = $table.next()
      for el in $sources.find('dt, dd')
        thisLine.push($(el).text())
        if el.name == 'dd'
          endLine()
      ret.body = lines.join("\n\n")

    done(null, ret)

module.exports = HtmlParser
