module.exports =
  domains: [ 'snopes.com', 'www.snopes.com' ]
  parse: (url, $, h) ->
    $article = $('td.contentColumn')

    # Search for "Last updated:" in a <b> within a <font>. The next text node is the date.
    publishedAt = null
    for b in $article.find('b')
      if b.children[0]?.data == 'Last updated:'
        timeText = b.parent.next?.data
        break
    if timeText?
      publishedAt = h.moment.tz(timeText, 'D MMMM YYYY', 'America/Los_Angeles')

    # Parse the body. This is hard.
    lines = []
    thisLine = []
    endLine = ->
      s = thisLine.map((s) -> s.trim()).filter((s) -> s != '').join(' ')
      if s != ''
        lines.push(s)
      thisLine = []
    walk = (parent) ->
      for el in parent.children # walk the DOM: we need text nodes
        if el.type == 'text'
          thisLine.push(el.data)
        else if el.type == 'tag'
          if el.name == 'br'
            endLine()
          else if el.name == 'noindex' # MIXTURE / TRUE / FALSE lines
            lines.push(line) for line in h.texts($(el).find('td[valign=TOP]'))
          else if el.name == 'font'
            walk(el)
          else if el.name == 'div'
            endLine()
            walk(el)
            endLine()
          else if el.name == 'table'
            # do not parse. This is an ad.
          else
            thisLine.push($(el).text())
    walk($('.article_text')[0])
    endLine()
    lines.pop() # copyright
    lines.pop() # "last updated"
    $table = $('.article_text').next().next()
    lines.push($table.text().trim())
    $sources = $table.next()
    for el in $sources.find('dt, dd')
      thisLine.push($(el).text())
      if el.name == 'dd'
        endLine()

    source: 'Snopes'
    headline: $article.find('h1').text()
    byline: []
    publishedAt: publishedAt
    body: lines
