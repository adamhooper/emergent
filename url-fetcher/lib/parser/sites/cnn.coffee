module.exports =
  domains: [ 'www.cnn.com' ]
  parse: (url, $, h) ->
    # e.g., "By Chief Washington Correspondent Jake Tapper, Nick Paton Walsh and Sherisse Pham, CNN"
    bylines = $('.cnnByline').text()
      .substr(3)
      .replace(/Chief \w+ Correspondent /g, '')
      .split(/\s*,\s+|\s+and\s+/g)
      .filter((s) -> s != 'CNN')

    timeText = $('.cnn_strytmstmp').text() # e.g., "updated 6:27 AM EDT, Fri April 18, 2014"
    if (m = /(\d\d?):(\d\d) ([AP]M) (\w\w\w), \w+ (\w+) (\d\d?), (\d\d\d\d)/.exec(timeText))?
      # Rewrite the string to Moment can parse it. (Moment doesn't do "EDT" inline)
      m = h.moment.tz("#{m[7]} #{m[5]} #{m[6]} #{m[1]} #{m[2]} #{m[3]}", 'YYYY MMMM D h:mm A', m[4])

    source: 'CNN'
    headline: $('.cnn_storyarea h1').text()
    publishedAt: m
    byline: bylines
    body: h.texts($('.cnn_strycntntlft p'))
