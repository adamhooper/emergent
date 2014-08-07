cheerio = require('cheerio')
moment = require('moment-timezone')

# Western news websites use a few abbreviations for timezones. In theory there
# could be conflicts, but most of the time these are correct. (If there are
# conflicts on a particular news website, we can specify different date-parsing
# logic in that news website's parse() method.)
#
# Wonky syntax is because moment-timezone breaks if we re-link the same zone.
for [ short, long ] in [
  [ 'ET', 'America/New_York' ]
  [ 'EDT', 'America/New_York' ]
  [ 'EST', 'America/New_York' ]
  [ 'PDT', 'America/Los_Angeles' ]
  [ 'PST', 'America/Los_Angeles' ]
]
  if !moment.tz.zone(short)?
    moment.tz.link("#{long}|#{short}")

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
    $els.map(-> $(@).text().trim())
      .toArray()
      .filter((s) -> s) # trim empty lines

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

    # All but publishedAt must be non-null in actual code. But null can be
    # handy during test-driven development, so we handle it on byline/body.
    source: ret.source ? ''
    headline: ret.headline ? ''
    byline: ret.byline?.join(', ') ? ''
    publishedAt: ret.publishedAt?.toDate?() ? ret.publishedAt
    body: ret.body?.join("\n\n") ? ''

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

singleton = new HtmlParser()

# Load all SiteParsers
fs = require('fs')
SiteParser = require('./site_parser')
for codeFile in fs.readdirSync("#{__dirname}/sites")
  m = require("#{__dirname}/sites/#{codeFile.substring(0, codeFile.length - ".coffee".length)}")
  siteParser = new SiteParser()
  siteParser[k] = v for k, v of m
  singleton.addSiteParser(siteParser)

HtmlParser.parse = (args...) -> singleton.parse(args...)

module.exports = HtmlParser
