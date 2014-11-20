cheerio = require('cheerio')
_ = require('lodash')

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

  domain: (url) ->
    m = /https?:\/\/([^\/]+)/.exec(url)
    m?[1]

class HtmlParser
  constructor: ->
    @siteParsers = []

  addSiteParser: (siteParser) ->
    @siteParsers.push(siteParser)

  _doParse: (url, html, siteParser) ->
    $ = cheerio.load(html, normalizeWhitespace: true)
    h = new Helpers($)
    ret = siteParser.parse(url, $, h)

    toArray = (x) ->
      x = h.texts(x) if x?.text? # Cheerio object
      x || []

    toString = (x) ->
      if _.isString(x)
        x
      else if x
        x = toArray(x) # Cheerio object -> String(s)
        x[0] || '' # Array -> String
      else
        ''

    toDate = (x) ->
      if _.isDate(x) # Date
        x
      else if x?.toDate? # Moment
        x.toDate()
      else if x
        x = toString(x)
        new Date(x)
      else
        null

    # All must be non-null in actual code. But null can be handy during
    # test-driven development, so we handle it on byline/body.
    source: toString(ret.source)
    headline: toString(ret.headline)
    byline: toArray(ret.byline).join(", ")
    body: toArray(ret.body).join("\n\n")
    parserVersion: siteParser.version

  # Finds the appropriate SiteParser for the given URL.
  #
  # Returns `null` if there is none.
  urlToSiteParser: (url) ->
    for siteParser in @siteParsers
      if siteParser.testUrl(url)
        return siteParser

    null

  # Parses the HTML at the given URL. Returns an Object like this:
  #
  #   {
  #     source: ''         # e.g., "The New York Times"
  #     headline: ''       # e.g., "Dog bites man". Don't worry about capitals.
  #     byline: ''         # e.g., "Adam Hooper, Craig Silverman"
  #     body: "foo\n\nbar" # paragraphs separated by two newlines
  #   }
  parse: (url, html) ->
    siteParser = @urlToSiteParser(url)

    if siteParser
      return @_doParse(url, html, siteParser)
    else
      throw new Error("No SiteParser exists to handle the URL #{url}")

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
HtmlParser.urlToSiteParser = (args...) -> singleton.urlToSiteParser(args...)

module.exports = HtmlParser
