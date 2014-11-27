module.exports =
  domains: [ 'dailybuzzlive.com' ]
  parse: (url, $, h) ->
    $('a[href="https://www.facebook.com/DailyViralBuzz"]').remove()

    source: 'Daily Buzz Live'
    headline: $('h1.entry-title')
    byline: $('span.author.vcard')
    body: $('.entry-content p')
