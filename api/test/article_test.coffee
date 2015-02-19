_ = require('lodash')

createUrlVersion = (urlId, attrs) ->
  attrs = _.extend({
    urlId: urlId
    source: 'source'
    byline: 'byline'
    headline: 'headline'
    body: 'body'
    createdAt: new Date()
    updatedAt: new Date()
  }, attrs)

  models.UrlVersion.create(attrs, raw: true)

createArticleVersion = (articleId, articleVersionAttrs, urlId, urlVersionAttrs) ->
  createUrlVersion(urlId, urlVersionAttrs)
    .then (urlVersion) ->
      attrs = _.extend({}, {
        articleId: articleId
        urlVersionId: urlVersion.id
        createdAt: new Date()
        updatedAt: new Date()
      }, articleVersionAttrs)
      models.ArticleVersion.create(attrs, raw: true)

createPopularity = (urlId, service, shares, at) ->
  models.UrlPopularityGet.create({
    urlId: urlId
    service: service
    shares: shares
    createdAt: at
  }, raw: true)

describe 'GET /claims/:claimId/articles', ->
  beforeEach ->
    @go = =>
      api.get("/claims/#{@claim.id}/articles")
        .tap((res) -> throw new Error(res.body) if res.status == 500)

    models.Story.create({
      slug: 'a-slug'
      headline: 'claim-headline'
      description: 'claim-description'
    }, 'admin@example.org')
      .tap((x) => @claim = x)

  describe 'when the claim is missing', ->
    it 'should return 404', ->
      api.get('/claims/99cb4e57-44a3-4d8b-bf09-dbda8e09d9df/articles')
        .tap((res) -> expect(res.status).to.eq(404))

  describe 'when the :claimId parameter is not a UUID', ->
    it 'should return 404', ->
      api.get('/claims/99cb4e57-44a3-4d8b-bf09-dbda8e09d9d/articles')
        .tap((res) -> expect(res.status).to.eq(404))

  describe 'when the claim has no Articles', ->
    it 'should return an empty Array', ->
      @go().tap((res) -> expect(res.body).to.deep.eq([]))

  describe 'with one Article', ->
    beforeEach ->
      models.Url.create(
        url: 'http://example.org'
        cachedNSharesFacebook: 1
        cachedNSharesGoogle: 2
        cachedNSharesTwitter: 3
      )
        .then((x) => @url1 = x)
        .then => models.Article.create({ storyId: @claim.id, urlId: @url1.id, createdAt: new Date(1000) }, 'admin@example.org')
        .then((x) => @article = x)

    it 'should show nulls when there are no ArticleVersions', ->
      @go()
        .tap (res) =>
          expect(res.body).to.deep.eq([{
            id: @article.id
            url: 'http://example.org'
            articleVersionId: null # TODO nix
            source: null # TODO nix
            headline: null
            byline: null # TODO nix
            createdAt: '1970-01-01T00:00:01.000Z'
            nShares:
              facebook: 1
              google: 2
              twitter: 3
            firstVersion:
              articleVersionId: null
              byline: null
              createdAt: null
              headline: null
              urlGetId: null
              urlVersionId: null
            latestVersion:
              articleVersionId: null
              byline: null
              createdAt: null
              headline: null
              urlGetId: null
              urlVersionId: null
          }])

    it 'should show first and lass ArticleVersion as one when there is one ArticleVersion', ->
      createArticleVersion(@article.id, { createdAt: new Date(2000) }, @url1.id, { headline: 'h1', byline: 'b1', source: 'deleteme', createdAt: new Date(2000) })
        .then((x) => @av1 = x)
        .then(=> @go())
        .tap (res) =>
          expect(res.body).to.deep.eq([{
            id: @article.id
            url: 'http://example.org'
            articleVersionId: @av1.id # TODO nix
            source: 'deleteme' # TODO nix
            headline: 'h1' # TODO nix
            byline: 'b1' # TODO nix
            createdAt: '1970-01-01T00:00:01.000Z'
            nShares:
              facebook: 1
              google: 2
              twitter: 3
            firstVersion:
              articleVersionId: @av1.id
              byline: 'b1'
              createdAt: '1970-01-01T00:00:02.000Z'
              headline: 'h1'
              urlGetId: null
              urlVersionId: @av1.urlVersionId
            latestVersion:
              articleVersionId: @av1.id
              byline: 'b1'
              createdAt: '1970-01-01T00:00:02.000Z'
              headline: 'h1'
              urlGetId: null
              urlVersionId: @av1.urlVersionId
          }])

    it 'should show first and last ArticleVersion when there are two', ->
      Promise.all([
        createArticleVersion(@article.id, { createdAt: new Date(2000) }, @url1.id, { headline: 'h1', byline: 'b1', source: 'deleteme', createdAt: new Date(2000) })
        createArticleVersion(@article.id, { createdAt: new Date(3000) }, @url1.id, { headline: 'h2', byline: 'b2', source: 'deleteme', createdAt: new Date(3000) })
      ])
        .then(([x1, x2]) => @av1 = x1; @av2 = x2)
        .then(=> @go())
        .tap (res) =>
          expect(res.body).to.deep.eq([{
            id: @article.id
            url: 'http://example.org'
            articleVersionId: @av2.id # TODO nix
            source: 'deleteme' # TODO nix
            headline: 'h2' # TODO nix
            byline: 'b2' # TODO nix
            createdAt: '1970-01-01T00:00:01.000Z'
            nShares:
              facebook: 1
              google: 2
              twitter: 3
            firstVersion:
              articleVersionId: @av1.id
              byline: 'b1'
              createdAt: '1970-01-01T00:00:02.000Z'
              headline: 'h1'
              urlGetId: null
              urlVersionId: @av1.urlVersionId
            latestVersion:
              articleVersionId: @av2.id
              byline: 'b2'
              createdAt: '1970-01-01T00:00:03.000Z'
              headline: 'h2'
              urlGetId: null
              urlVersionId: @av2.urlVersionId
          }])

    it 'should show first and last ArticleVersion when there are more than two', ->
      Promise.all([
        createArticleVersion(@article.id, { createdAt: new Date(2000) }, @url1.id, { headline: 'h1', byline: 'b1', source: 'deleteme', createdAt: new Date(2000) })
        createArticleVersion(@article.id, { createdAt: new Date(2400) }, @url1.id, { headline: 'hmid', byline: 'bmid', source: 'deleteme', createdAt: new Date(2400) })
        createArticleVersion(@article.id, { createdAt: new Date(3000) }, @url1.id, { headline: 'h2', byline: 'b2', source: 'deleteme', createdAt: new Date(3000) })
      ])
        .then(([x1, xmid, x2]) => @av1 = x1; @av2 = x2)
        .then(=> @go())
        .tap (res) =>
          expect(res.body).to.deep.eq([{
            id: @article.id
            url: 'http://example.org'
            articleVersionId: @av2.id # TODO nix
            source: 'deleteme' # TODO nix
            headline: 'h2' # TODO nix
            byline: 'b2' # TODO nix
            createdAt: '1970-01-01T00:00:01.000Z'
            nShares:
              facebook: 1
              google: 2
              twitter: 3
            firstVersion:
              articleVersionId: @av1.id
              byline: 'b1'
              createdAt: '1970-01-01T00:00:02.000Z'
              headline: 'h1'
              urlGetId: null
              urlVersionId: @av1.urlVersionId
            latestVersion:
              articleVersionId: @av2.id
              byline: 'b2'
              createdAt: '1970-01-01T00:00:03.000Z'
              headline: 'h2'
              urlGetId: null
              urlVersionId: @av2.urlVersionId
          }])

  describe 'with two Articles', ->
    beforeEach ->
      Promise.all([
        models.Url.create(url: 'http://example.org/1')
        models.Url.create(url: 'http://example.org/2')
      ])
        .then(([ x1, x2 ]) => @url1 = x1; @url2 = x2)
        .then(=> Promise.all([
          models.Article.create({ storyId: @claim.id, urlId: @url1.id, createdAt: new Date(1001) }, 'admin@example.org')
          models.Article.create({ storyId: @claim.id, urlId: @url2.id, createdAt: new Date(1002) }, 'admin@example.org')
        ]))
        .then(([ x1, x2 ]) => @article1 = x1; @article2 = x2)

    it 'should group data by Article', ->
      Promise.all([
        createArticleVersion(@article1.id, { createdAt: new Date(2001) }, @url1.id, { headline: 'h1', byline: 'b1', source: 'deleteme', createdAt: new Date(2001) })
        createArticleVersion(@article2.id, { createdAt: new Date(3002) }, @url2.id, { headline: 'h2', byline: 'b2', source: 'deleteme', createdAt: new Date(3002) })
      ])
        .then(([x1, x2]) => @av1 = x1; @av2 = x2)
        .then(=> @go())
        .tap (res) =>
          expect(res.body).to.deep.eq([{
            id: @article2.id
            url: 'http://example.org/2'
            articleVersionId: @av2.id # TODO nix
            source: 'deleteme' # TODO nix
            headline: 'h2' # TODO nix
            byline: 'b2' # TODO nix
            createdAt: '1970-01-01T00:00:01.002Z'
            nShares:
              facebook: 0
              google: 0
              twitter: 0
            firstVersion:
              articleVersionId: @av2.id
              byline: 'b2'
              createdAt: '1970-01-01T00:00:03.002Z'
              headline: 'h2'
              urlGetId: null
              urlVersionId: @av2.urlVersionId
            latestVersion:
              articleVersionId: @av2.id
              byline: 'b2'
              createdAt: '1970-01-01T00:00:03.002Z'
              headline: 'h2'
              urlGetId: null
              urlVersionId: @av2.urlVersionId
          }, {
            id: @article1.id
            url: 'http://example.org/1'
            articleVersionId: @av1.id # TODO nix
            source: 'deleteme' # TODO nix
            headline: 'h1' # TODO nix
            byline: 'b1' # TODO nix
            createdAt: '1970-01-01T00:00:01.001Z'
            nShares:
              facebook: 0
              google: 0
              twitter: 0
            firstVersion:
              articleVersionId: @av1.id
              byline: 'b1'
              createdAt: '1970-01-01T00:00:02.001Z'
              headline: 'h1'
              urlGetId: null
              urlVersionId: @av1.urlVersionId
            latestVersion:
              articleVersionId: @av1.id
              byline: 'b1'
              createdAt: '1970-01-01T00:00:02.001Z'
              headline: 'h1'
              urlGetId: null
              urlVersionId: @av1.urlVersionId
          }])

describe '/articles/:id/stances-over-time', ->
  beforeEach ->
    models.Story.create({
      slug: 'a-slug'
      headline: 'A Headline'
      description: 'A Description'
      origin: 'An Origin'
      originUrl: 'http://example.org'
      publishedAt: new Date(1)
      truthiness: 'true'
      truthinessDescription: 'truthiness described'
      truthinessDate: new Date(1000)
      truthinessUrl: 'http://example2.org'
      createdAt: new Date(2000)
      createdBy: 'user@example.org'
      updatedAt: new Date(3000)
      updatedBy: 'user2@example.org'
    }, raw: true)
      .then((x) => @claim = x)

  describe 'when the Article is missing', ->
    it 'should return 404', ->
      api.get('/articles/99cb4e57-44a3-4d8b-bf09-dbda8e09d9df/stances-over-time')
        .then (res) ->
          expect(res.status).to.eq(404)

  describe 'with an Article', ->
    beforeEach ->
      @go = =>
        api.get("/articles/#{@article.id}/stances-over-time")
          .tap((res) -> throw new Error(res.body) if res.status == 500)
      models.Url.create(url: 'http://example.org')
        .then((url) => @url = url)
        .then => models.Article.create({ storyId: @claim.id, urlId: @url.id }, 'user@example.org')
        .then((article) => @article = article)

    describe 'when there are no ArticleVersions', ->
      it 'should return []', ->
        @go()
          .then (res) ->
            expect(res.status).to.eq(200)
            expect(res.body).to.deep.eq([])

      it 'should return [] even if there are UrlPopularityGets', ->
        createPopularity(@url.id, 'facebook', 10, new Date(1000))
          .then(=> @go())
          .then (res) ->
            expect(res.status).to.eq(200)
            expect(res.body).to.deep.eq([])

    describe 'with a single ArticleVersion', ->
      beforeEach ->
        createArticleVersion(@article.id, { stance: 'for', headlineStance: 'against' }, @url.id, {})
          .then((v) => @version = v)

      it 'should return the one stance', ->
        @go()
          .then (res) =>
            expect(res.body).to.deep.eq([{
              articleVersionIds: [ @version.id ]
              stance: 'for'
              headlineStance: 'against'
              comment: ''
              startTime: @version.createdAt.toISOString()
              endDate:
                min: @version.createdAt.toISOString()
                max: null
                guess: null
              endShares:
                min: {}
                max: {}
                guess: {}
            }])

      it 'should set min endShares to the last share count', ->
        Promise.all([
          createPopularity(@url.id, 'facebook', 10, new Date(1000))
          createPopularity(@url.id, 'facebook', 5, new Date(2000))
        ])
          .then(=> @go())
          .then (res) ->
            expect(res.body[0].endShares.min.facebook).to.deep.eq
              shares: 5
              date: new Date(2000).toISOString()

    describe 'with multiple versions at same stance', ->
      beforeEach ->
        Promise.all([
          createArticleVersion(@article.id, { stance: 'for', headlineStance: 'against', createdAt: new Date(3000) }, @url.id, {})
          createArticleVersion(@article.id, { stance: 'for', headlineStance: 'against', createdAt: new Date(6000) }, @url.id, {})
        ])
          .spread (v1, v2) =>
            @v1 = v1
            @v2 = v2

      it 'should return the one stance', ->
        @go()
          .then (res) =>
            expect(res.body).to.deep.eq([{
              articleVersionIds: [ @v1.id, @v2.id ]
              stance: 'for'
              headlineStance: 'against'
              comment: ''
              startTime: @v1.createdAt.toISOString()
              endDate:
                min: @v2.createdAt.toISOString()
                max: null
                guess: null
              endShares:
                min: {}
                max: {}
                guess: {}
            }])

      it 'should set min endShares to the last share count', ->
        Promise.all([
          createPopularity(@url.id, 'facebook', 10, new Date(1000))
          createPopularity(@url.id, 'facebook', 5, new Date(2000))
        ])
          .then(=> @go())
          .then (res) ->
            expect(res.body[0].endShares.min.facebook).to.deep.eq
              shares: 5
              date: new Date(2000).toISOString()

    describe 'with differring stances', ->
      beforeEach ->
        Promise.all([
          createArticleVersion(
            @article.id,
            { stance: 'for', headlineStance: 'against', createdAt: new Date(3000) },
            @url.id,
            { createdAt: new Date(3000) }
          )
          createArticleVersion(
            @article.id,
            { stance: 'for', headlineStance: 'for', createdAt: new Date(6000) },
            @url.id,
            { millisecondsSincePreviousUrlGet: 1000, createdAt: new Date(6000) }
          )
        ])
          .spread (v1, v2) =>
            @v1 = v1
            @v2 = v2

      it 'should return the two stances', ->
        @go().then (res) =>
          expect(res.body).to.deep.eq([{
            articleVersionIds: [ @v1.id ]
            stance: 'for'
            headlineStance: 'against'
            comment: ''
            startTime: new Date(3000).toISOString()
            endDate:
              min: new Date(5000).toISOString()
              max: new Date(6000).toISOString()
              guess: new Date(5500).toISOString()
            endShares:
              min: {}
              max: {}
              guess: {}
          }, {
            articleVersionIds: [ @v2.id ]
            stance: 'for'
            headlineStance: 'for'
            comment: ''
            startTime: new Date(6000).toISOString()
            endDate:
              min: new Date(6000).toISOString()
              max: null
              guess: null
            endShares:
              min: {}
              max: {}
              guess: {}
          }])

      describe 'with shares interspersed', ->
        beforeEach ->
          Promise.all([
            createPopularity(@url.id, 'facebook', 5, new Date(0))
            # v1: 3000 begins...
            createPopularity(@url.id, 'facebook', 15, new Date(3500))
            # ... v1 ends at 5000
            createPopularity(@url.id, 'facebook', 20, new Date(5200))
            # v2: 6000-null
            createPopularity(@url.id, 'facebook', 25, new Date(7000))
          ])

        it 'should set endShares.min properly', ->
          @go().then (res) ->
            expect(res.body.map((x) -> x.endShares.min.facebook)).to.deep.eq([
              { shares: 15, date: new Date(3500).toISOString() }
              { shares: 20, date: new Date(5200).toISOString() }
            ])

        it 'should set endShares.max properly', ->
          @go().then (res) ->
            expect(res.body.map((x) -> x.endShares.max.facebook)).to.deep.eq([
              { shares: 25, date: new Date(7000).toISOString() } # endTime.max = 6000
              { shares: null, date: null }
            ])

        it 'should interpolate endShares.guess between min and max, at endDate.guess', ->
          # endDate.guess = 5500
          # min = 20@5200
          # max = 25@7000
          # ... on line x=5200..7000 and y=20..25, value at x=5500 =~ 21
          @go().then (res) ->
            expect(res.body[0].endShares.guess.facebook).to.deep.eq
              shares: 21
              date: new Date(5500).toISOString()

        it 'should set endShares.guess to the max on the last entry', ->
          @go().then (res) ->
            expect(res.body[1].endShares.guess.facebook).to.deep.eq
              shares: 25
              date: null

      describe 'with first fetch happening before first share', ->
        beforeEach ->
          Promise.all([
            # v1: 3000 begins...
            createPopularity(@url.id, 'facebook', 15, new Date(3500))
            # ... v1 ends at 5000
            createPopularity(@url.id, 'facebook', 20, new Date(5200))
            # v2: 6000-null
            createPopularity(@url.id, 'facebook', 25, new Date(7000))
          ])

        it 'should set endShares.min properly', ->
          @go().then (res) ->
            expect(res.body.map((x) -> x.endShares.min.facebook)).to.deep.eq([
              { shares: 15, date: new Date(3500).toISOString() }
              { shares: 20, date: new Date(5200).toISOString() }
            ])

      describe 'with second fetch happening before first share', ->
        beforeEach ->
          Promise.all([
            # v1: 3000 begins...
            # ... v1 ends at 5000
            # v2: 6000-null
            createPopularity(@url.id, 'facebook', 25, new Date(7000))
          ])

        it 'should set endShares.min properly', ->
          @go().then (res) ->
            expect(res.body.map((x) -> x.endShares.min.facebook)).to.deep.eq([
              { shares: 0, date: null }
              { shares: 0, date: null }
            ])

        #... do we care about this?
        #it 'should sent endShares.guess to max on the last one', ->
        #  @go().then (res) ->
        #    expect(res.body[0].endShares.guess.facebook).to.deep.eq({ shares: 0, date: null })
        #    expect(res.body[1].endShares.guess.facebook).to.deep.eq({ shares: 25, date: new Date(7000) })
