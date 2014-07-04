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
    m = /^https?:\/\/([^\/]+)\//.exec(url)
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
  #     publishedAt: null # a Moment (http://momentjs.com), a Date, or `null`
  #     byline: []        # an Array of String author names.
  #     body: []          # an Array of String body text lines
  #   }
  #
  # Ensure that publishedAt has the timezone applied. If you're parsing a
  # website that doesn't mention the timezone, assume the timezone based on the
  # website's location. For instance, Snopes is in California, so parse its
  # time in then `"America/Los_Angeles"` timezone. (This is why we integrate
  # with MomentJS.)
  #
  # Arguments:
  #   url: the URL being parsed.
  #   $: a Cheerio object. (https://matthewmueller.github.io/cheerio/)
  parse: (url, $) -> throw new Error('not implemented')
