_ = require('lodash')
Promise = require('bluebird')

models = require('../../data-store').models
MultiPointCurve = require('../../api/lib/multi_point_curve')
MaxDate = new Date(8640000000000000)

# Mostly copy/pasted from ../api/controllers/article.coffee, then tweaked

class ShareCurve
  constructor: (popularities) ->
    points = ([ p.createdAt.valueOf(), p.shares ] for p in popularities)
    @curve = new MultiPointCurve(points)

  _toNumber: (d) ->
    if d?
      new Date(d).valueOf()
    else
      null

  atOrBefore: (date) ->
    x = @_toNumber(date)
    p = @curve.xyAtOrBefore(x)
    if x? && p?
      { shares: p[1], date: new Date(p[0]) }
    else
      { shares: 0, date: null }

  atOrAfter: (date) ->
    x = @_toNumber(date)
    p = @curve.xyAtOrAfter(x)
    if x? && p?
      { shares: p[1], date: new Date(p[0]) }
    else
      { shares: null, date: null }

  guessAt: (date) ->
    x = @_toNumber(date)
    y = @curve.yAt(x)
    if x? && y?
      { shares: Math.round(y), date: new Date(date) }
    else
      { shares: null, date: new Date(date) }

# Accepts UrlPopularityGets.
# Returns { facebook: MultiPointCurve(date, shares), ... }
popularitiesToShareCurves = (popularities) ->
  ret = {}
  for service, ps of _.groupBy(popularities, 'service')
    ret[service] = new ShareCurve(ps)
  ret

# Returns a JSON object per stance of the article
articleToSlices = (article) ->
  slices = []

  versions = article.articleVersions
  urlVersions = article.urlVersions.slice()
  popularities = article.urlPopularityGets

  versionNumber = 0
  lastStance = undefined # null != undefined
  lastHeadlineStance = undefined # null != undefined
  nextSlice = undefined

  if versions.length != urlVersions.length
    console.warn("Skipping article #{article.id} url #{article.url.id} #{article.url.url} story #{article.story.slug} because ArticleVersions has #{versions.length} rows and UrlVersions has #{urlVersions.length} rows (they must be equal)")
    return []

  for version in versions
    urlVersion = urlVersions.shift()
    versionNumber++

    if version.stance != nextSlice?.stance || version.headlineStance != nextSlice?.headlineStance
      # Change of stance! Write the last one if it exists
      if nextSlice?
        if (ms = urlVersion.millisecondsSincePreviousUrlGet)?
          nextSlice.endDate.min = new Date(Math.max(
            nextSlice.endDate.min?.valueOf(),
            version.createdAt - ms
          ))
        slices.push(nextSlice)

      nextSlice =
        slug: article.story.slug
        truthiness: article.story.truthiness
        url: article.url.url
        versionNumber: versionNumber
        stance: version.stance
        headlineStance: version.headlineStance
        previousStance: nextSlice?.stance
        previousHeadlineStance: nextSlice?.headlineStance
        source: urlVersion.source
        comment: version.comment # the first one is usually the one we want
        startTime: version.createdAt
        endDate:
          min: null
          max: null
          guess: null

    # Whether or not we're on a new stance, mark that we've seen this version
    nextSlice.endDate.min = version.createdAt # always a lower bound

  # Done. Let's jot down our last stance....
  slices.push(nextSlice) if nextSlice?

  # Set endDate.max, endDate.guess
  if slices.length > 0
    for i in [0...(slices.length-1)]
      endDate = slices[i].endDate
      endDate.max = slices[i + 1].startTime
      endDate.guess = new Date((endDate.min.valueOf() + endDate.max.valueOf()) / 2)

  # Set endShares
  shareCurves = popularitiesToShareCurves(popularities)
  for slice in slices
    endDate = slice.endDate
    slice.endShares = endShares = { min: {}, max: {}, guess: {} }
    for service, curve of shareCurves
      endShares.min[service] = curve.atOrBefore(endDate.min)
      endShares.max[service] = curve.atOrAfter(endDate.max)
      if endDate.guess?
        endShares.guess[service] = curve.guessAt(endDate.guess)
      else
        endShares.guess[service] = curve.atOrBefore(MaxDate)
        endShares.guess[service].date = null

  slices

Promise.all([
  models.Story.findAll({}, raw: true)
  models.Article.findAll({}, raw: true)
  models.Url.findAll({}, raw: true)
  models.ArticleVersion.findAll({ order: [[ 'createdAt' ]] }, raw: true)
  models.UrlVersion.findAll({ order: [[ 'createdAt' ]] }, raw: true)
  models.UrlPopularityGet.findAll({ order: [[ 'createdAt' ]] }, raw: true)
])
  .spread (stories, articles, urls, articleVersions, urlVersions, popularities) ->
    # Index stories
    idToStory = {}
    (idToStory[s.id] = s) for s in stories

    # Index urls
    idToUrl = {}
    (idToUrl[u.id] = u) for u in urls

    # Group into articles
    for article in articles
      article.story = idToStory[article.storyId]
      article.url = idToUrl[article.urlId]
      # O(n^2) because it's probably faster than being clever
      article.articleVersions = (av for av in articleVersions when av.articleId == article.id)
      article.urlVersions = (uv for uv in urlVersions when uv.urlId == article.urlId)
      article.urlPopularityGets = (upg for upg in popularities when upg.urlId == article.urlId)

    articles
  .then (articles) ->
    jsons = []
    for article in articles
      for slice in articleToSlices(article)
        jsons.push(slice)
    jsons
  .then (jsons) ->
    quote = (s) ->
      # https://tools.ietf.org/html/rfc4180#section-2
      if /^[\u0020-\u0021\u0023-\u002b\u002d-\u007e]*$/.test(s)
        s
      else
        '"' + s.replace('"', '""') + '"'

    date = (d) -> d?.toISOString() || ''

    for json in jsons
      [
        quote(json.slug)
        json.truthiness || ''
        quote(json.url)
        json.versionNumber
        quote(json.source)
        json.stance || ''
        json.headlineStance || ''
        json.previousStance || ''
        json.previousHeadlineStance || ''
        date(json.startTime)
        date(json.endDate.min)
        date(json.endDate.max)
        date(json.endDate.guess)
        json.endShares.min.facebook?.shares || ''
        json.endShares.min.google?.shares || ''
        json.endShares.min.twitter?.shares || ''
        json.endShares.max.facebook?.shares || ''
        json.endShares.max.google?.shares || ''
        json.endShares.max.twitter?.shares || ''
        json.endShares.guess.facebook?.shares || ''
        json.endShares.guess.google?.shares || ''
        json.endShares.guess.twitter?.shares || ''
      ]
  .tap (rows) ->
    process.stdout.write([
      'slug'
      'truthiness'
      'url'
      'versionNumber'
      'source'
      'stance'
      'headlineStance'
      'previousStance'
      'previousHeadlineStance'
      'startDate'
      'endDateMin'
      'endDateMax'
      'endDateGuess'
      'endSharesMinFacebook'
      'endSharesMinGoogle'
      'endSharesMinTwitter'
      'endSharesMaxFacebook'
      'endSharesMaxGoogle'
      'endSharesMaxTwitter'
      'endSharesGuessFacebook'
      'endSharesGuessGoogle'
      'endSharesGuessTwitter'
    ].join(',') + '\r\n')
    for row in rows
      process.stdout.write(row.join(',') + '\r\n')
  .catch (err) ->
    console.warn(err)
    console.warn(err.stack)
