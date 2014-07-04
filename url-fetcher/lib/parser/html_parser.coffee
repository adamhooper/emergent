cheerio = require('cheerio')
moment = require('moment-timezone')

class Helpers
  constructor: (@$) ->

  # Returns the text of each element in the Cheerio object.
  #
  # For instance,
  #
  #   h.texts($('<ul><li>foo</li><li>bar</li></ul>').children())
  #
  # Will return:
  #
  #   [ 'foo', 'bar' ]
  texts: ($els) ->
    $ = @$
    $els.map(-> $(@).text().trim()).toArray()

  moment: moment

class HtmlParser
  constructor: ->
    @siteParsers = []

  addSiteParser: (siteParser) ->
    @siteParsers.push(siteParser)

  _doParse: (url, html, siteParser) ->
    $ = cheerio.load(html, normalizeWhitespace: true)
    h = new Helpers($)
    ret = siteParser.parse(url, $, h)

    source: ret.source
    headline: ret.headline
    byline: ret.byline.join(', ')
    publishedAt: ret.publishedAt?.toDate?() ? ret.publishedAt
    body: ret.body.join("\n\n")

  # Parses the HTML at the given URL. Returns an Object like this:
  #
  #   {
  #     source: ''         # e.g., "The New York Times"
  #     headline: ''       # e.g., "Dog bites man". Don't worry about capitals.
  #     byline: ''         # e.g., "Adam Hooper, Craig Silverman"
  #     publishedAt: null  # or a Date object
  #     body: "foo\n\nbar" # paragraphs separated by two newlines
  #   }
  #
  # Why is this an async method? Because it will be a bit slower than others.
  # In the future, we may consider offloading this work to another machine.
  # This way, we don't need to rewrite our tests when we do.
  parse: (url, html, done) ->
    ret = null

    for siteParser in @siteParsers
      if siteParser.testUrl(url)
        ret = @_doParse(url, html, siteParser)
        break

    if ret?
      done(null, ret)
    else
      done(new Error("No SiteParser exists to handle the URL #{url}"))

    #else if /^https?:\/\/(?:www\.)?snopes\.com\//.test(url)
    #  $article = $('td.contentColumn')
    #  ret.source = 'Snopes'
    #  ret.headline = $article.find('h1').text()
    #  ret.byline = ''
    #  # Search for "Last updated:" in a <b> within a <font>. The next text node is the date.
    #  for b in $article.find('b')
    #    if b.children[0]?.data == 'Last updated:'
    #      timeText = b.parent.next?.data
    #      break
    #  if timeText?
    #    m = moment.tz(timeText, 'D MMMM YYYY', 'America/Los_Angeles')
    #    ret.publishedAt = m.toDate()
    #  # Parse the body. This is hard.
    #  lines = []
    #  thisLine = []
    #  endLine = ->
    #    s = thisLine.map((s) -> s.trim()).filter((s) -> s != '').join(' ')
    #    if s != ''
    #      lines.push(s)
    #    thisLine = []
    #  walk = (parent) ->
    #    for el in parent.children # walk the DOM: we need text nodes
    #      if el.type == 'text'
    #        thisLine.push(el.data)
    #      else if el.type == 'tag'
    #        if el.name == 'br'
    #          endLine()
    #        else if el.name == 'noindex' # MIXTURE / TRUE / FALSE lines
    #          lines.push(line) for line in texts($, $(el).find('td[valign=TOP]'))
    #        else if el.name == 'font'
    #          walk(el)
    #        else if el.name == 'div'
    #          endLine()
    #          walk(el)
    #          endLine()
    #        else if el.name == 'table'
    #          # do not parse. This is an ad.
    #        else
    #          thisLine.push($(el).text())
    #  walk($('.article_text')[0])
    #  endLine()
    #  lines.pop() # copyright
    #  lines.pop() # "last updated"
    #  $table = $('.article_text').next().next()
    #  lines.push($table.text().trim())
    #  $sources = $table.next()
    #  for el in $sources.find('dt, dd')
    #    thisLine.push($(el).text())
    #    if el.name == 'dd'
    #      endLine()
    #  ret.body = lines.join("\n\n")
    #
    #done(null, ret)

singleton = new HtmlParser()

# Load all SiteParsers
fs = require('fs')
SiteParser = require('./site_parser')
for codeFile in fs.readdirSync("#{__dirname}/sites")
  m = require("#{__dirname}/sites/#{codeFile.split(/,/)[0]}")
  siteParser = new SiteParser()
  siteParser[k] = v for k, v of m
  singleton.addSiteParser(siteParser)

HtmlParser.parse = (args...) -> singleton.parse(args...)

module.exports = HtmlParser
