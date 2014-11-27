module.exports =
  domains: [ 'huzlers.com' ]
  parse: (url, $, h) ->
    # At the time of writing this, the entire website sits inside an
    # <h1 class="single-title"> because it's closed by a </h2>. That's why we
    # chose "h1.single-title a" instead of "h1.single-title".

    source: 'Huzlers'
    byline: $('.single-info a')
    headline: $('h1.single-title a')
    body: $('.single-archive p')
