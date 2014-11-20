fs = require('fs')
HtmlParser = require('../../lib/parser/html_parser')

describe 'HTML examples', ->
  normalizeBody = (text) ->
    text
      .split(/\n\n+/g)
      .map((s) -> s.trim().replace(/\s+/g, ' '))

  createExample = (label, url, html, expected) ->
    it "Should correctly parse #{label}", ->
      result = HtmlParser.parse(url, html)
      expect(result.headline).to.eq(expected.headline) if expected.headline?
      expect(result.byline).to.eq(expected.byline) if expected.byline?
      expect(result.source).to.eq(expected.source) if expected.source?
      expect(normalizeBody(result.body)).to.deep.eq(normalizeBody(expected.body)) if expected.body?

  dir = "#{__dirname}/data"
  for subdir in fs.readdirSync(dir)
    for jsonFile in fs.readdirSync("#{dir}/#{subdir}") when /\.json$/.test(jsonFile)
      name = "#{dir}/#{subdir}/#{jsonFile[0...-5]}"
      #console.log("Parsing #{name}.json...")
      json = JSON.parse(fs.readFileSync("#{name}.json"))
      html = fs.readFileSync("#{name}.html", "utf-8")
      txt = fs.readFileSync("#{name}.txt", "utf-8").trim()
      json.body = txt

      createExample(json.label, json.url, html, json)
