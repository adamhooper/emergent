# Parses a particular website. Implement child classes.
module.exports = class SiteParser
  # Does this SiteParser handle the given URL?
  #
  # Usually this is a regex match. For instance, a possible implementation is:
  #
  #     /^https?:\/\/www\.cnn\.com\/.test(url)
  #
  # But if you're testing the domain, you can override `domains` instead. The
  # default `testUrl()` implementation relies on them.
  testUrl: (url) ->
    # When optimizing: assume we'll be calling many different testUrl() methods
    # on the same URL.
    if (m = /^https?:\/\/([^\/]+)/.exec(url))?
      urlDomain = m[1]

      # When optimizing: assume there are one or two @domains.
      for domain in @domains
        return true if domain == urlDomain

    false

  # Domains this SiteParser supports.
  #
  # `testUrl()` is good in general, but often a SiteParser applies to all
  # stories from one or two domains (for instance, "snopes.com" or
  # "www.snopes.com").
  domains: []

  # Returns an Object that looks like this:
  #
  #   {
  #     source: ''        # e.g., "The New York Times"
  #     headline: ''      # e.g., "Dog bites man". Don't worry about capitals.
  #     byline: []        # an Array of String author names.
  #     body: []          # an Array of String body text lines
  #   }
  #
  # Arguments:
  #   url: the URL being parsed.
  #   $: a Cheerio object. (https://matthewmueller.github.io/cheerio/)
  #   h: a Helper object.
  parse: (url, $, h) -> throw new Error('not implemented')

  # The version of the parser.
  #
  # Override this version with a higher number to re-parse any UrlGets in the
  # database.
  version: 1
