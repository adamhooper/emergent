module.exports =
  domains: [ 'snopes.com', 'www.snopes.com' ]
  parse: (url, $, h) ->
    $article = $('td.contentColumn')
    $article.find('script').remove()

    # Parse the body. This is hard.
    lines = []
    thisLine = []
    endLine = ->
      s = thisLine
        .map((s) -> s.trim())
        .filter((s) -> s.length)
        .join(' ')
      if s != ''
        lines.push(s)
      thisLine = []
    walk = (parent) ->
      for el in parent.children # walk the DOM: we need text nodes
        if el.type == 'text'
          thisLine.push(el.data)
        else if el.type == 'tag'
          if el.name == 'script'
            # skip it
          else if el.name == 'br'
            endLine()
          else if el.name == 'font' || el.name == 'noindex' || el.name == 'table'
            walk(el)
          else if el.name == 'div' || el.name == 'tr'
            endLine()
            walk(el)
            endLine()
          else
            thisLine.push($(el).text())
        else
          # skip it -- probably a comment
    walk($('.article_text')[0])
    endLine()
    lines.pop() # copyright
    $table = $('.article_text').next().next()
    thisLine.push($table.text()); endLine()
    $sources = $table.next()
    for el in $sources.find('dt, dd')
      thisLine.push($(el).text())
      if el.name == 'dd'
        endLine()

    lines = lines.filter((s) -> s.length > 0)

    source: 'Snopes'
    headline: $article.find('h1').text()
    byline: []
    body: lines
