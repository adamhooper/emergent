module.exports =
  domains: [ 'www.gulf-times.com' ]
  parse: (url, $, h) ->
    $cal = $('.dateCalFormat')
    timeString = "#{$cal.find('.calYear').text().trim()} #{$cal.find('.calMonth').text().trim()} #{$cal.find('.calDay').text().trim()} #{$cal.find('.calTime').text().trim()}"

    source: 'Gulf Times'
    headline: $('#articledetails h1').text().trim()
    byline: [] # seems to be all wire copy
    publishedAt: h.moment.tz(timeString, 'YYYY MMMM DD h:mm A', 'Asia/Qatar')
    body: h.texts($('#ContentPlaceHolder1_spBody').children())
