module.exports =
  version: 3
  domains: [ 'www.cultofmac.com' ]
  parse: (url, $, h) ->
    $article = $('#main-content>.post, #content .post-entry') # CultOfMac switches output based on user-agent

    $byline = $article.find('[rel=author]') # before the remove()

    $article.find('script, div, p.comments-link').remove()

    source: 'Cult of Mac'
    headline: $('#main-content>.post h2, #content .post-title')
    byline: $byline
    body: $article.find('p')
