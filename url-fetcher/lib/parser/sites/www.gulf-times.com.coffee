module.exports =
  domains: [ 'www.gulf-times.com' ]
  parse: (url, $, h) ->
    source: 'Gulf Times'
    headline: $('#articledetails h1')
    byline: [] # seems to be all wire copy
    body: $('#ContentPlaceHolder1_spBody').children()
