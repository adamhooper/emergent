describe '/claims', ->
  beforeEach ->
    models.Story.create({
      slug: 'a-slug'
      headline: 'A Headline'
      description: 'A Description'
      origin: 'An Origin'
      originUrl: 'http://example.org'
      truthiness: 'true'
      truthinessDate: new Date(1000)
      createdAt: new Date(2000)
      createdBy: 'user@example.org'
      updatedAt: new Date(3000)
      updatedBy: 'user2@example.org'
    }, raw: true)
      .then((x) => @claim1 = x)
      .catch(console.warn)

  it 'should return the properties we want', ->
    api.get('/claims')
      .then (res) ->
        body = res.body
        claims = body.claims
        expect(claims).to.have.length(1)
        claim = claims[0]
        expect(claim.slug).to.eq('a-slug')
        expect(claim.headline).to.eq('A Headline')
        expect(claim.description).to.eq('A Description')
        expect(claim.origin).to.eq('An Origin')
        expect(claim.originUrl).to.eq('http://example.org')
        expect(claim.truthiness).to.eq('true')
        expect(claim.truthinessDate).to.eq(new Date(1000).toISOString())
        expect(claim.createdAt).to.eq(new Date(2000).toISOString())
        expect(claim).not.to.have.property('updatedAt')
        expect(claim).not.to.have.property('createdBy')
        expect(claim).not.to.have.property('updatedBy')
