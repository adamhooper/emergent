module.exports =
  version: 2
  domains: [ 'www.cultofmac.com' ]
  parse: (url, $, h) ->
    $contextly = $('meta[name="contextly-page"]')
    meta = JSON.parse($contextly.attr('content'))

    $article = $('#main-content>.post, #content .post-entry') # CultOfMac switches output based on user-agent
    $article.find('script, div, p.comments-link').remove()

    source: 'Cult of Mac'
    headline: meta.title
    byline: [ meta.author_name ]
    body: $article.find('p')
