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
        expect(result.body).to.eq(expected.body) if expected.body?
        done(err)

  dir = "#{__dirname}/data"
  for subdir in fs.readdirSync(dir)
    for jsonFile in fs.readdirSync("#{dir}/#{subdir}") when /\.json$/.test(jsonFile)
      json = JSON.parse(fs.readFileSync("#{dir}/#{subdir}/#{jsonFile}"))
      html = fs.readFileSync("#{dir}/#{subdir}/#{jsonFile[0...-5]}.html")

      createExample(json.label, json.url, html, json)
