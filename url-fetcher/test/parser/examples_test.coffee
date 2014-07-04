fs = require('fs')
HtmlParser = require('../../lib/parser/html_parser')

describe 'HTML examples', ->
  createExample = (label, url, html, expected) ->
    it "Should correctly parse #{label}", (done) ->
      HtmlParser.parse url, html, (err, result) ->
        expect(err).to.be.null
        expect(result.headline).to.eq(expected.headline) if expected.headline?
        expect(result.byline).to.eq(expected.byline) if expected.byline?
        expect(result.publishedAt?.toISOString()).to.eq(expected.publishedAt) if expected.publishedAt?
        expect(result.source).to.eq(expected.source) if expected.source?
        expect(result.body.split("\n\n")).to.deep.eq(expected.body.split("\n\n")) if expected.body?
        done(err)

  dir = "#{__dirname}/data"
  for subdir in fs.readdirSync(dir)
    for jsonFile in fs.readdirSync("#{dir}/#{subdir}") when /\.json$/.test(jsonFile)
      name = "#{dir}/#{subdir}/#{jsonFile[0...-5]}"
      json = JSON.parse(fs.readFileSync("#{name}.json"))
      html = fs.readFileSync("#{name}.html", "utf-8")
      txt = fs.readFileSync("#{name}.txt", "utf-8").trim()
      json.body = txt

      createExample(json.label, json.url, html, json)
