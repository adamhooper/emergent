describe 'CategoryController', ->
  models = require('../../../data-store').models
  Category = models.Category

  describe '#index', ->
    req = ->
      ret = supertest(app).get('/categories').set('Accept', 'application/json')
      Promise.promisify(ret.end, ret)()

    it 'should return JSON', ->
      req()
        .tap (res) ->
          expect(res.statusCode).to.eq(200)
          expect(res.headers['content-type']).to.equal('application/json; charset=utf-8')
          expect(res.body).to.deep.eq([])

    it 'should return sorted categories', ->
      Category.bulkCreate([{ name: 'foo' }, { name: 'bar' }, { name: 'baz' } ], 'user@example.org')
        .then -> req()
        .tap (res) ->
          categories = res.body
          expect(categories).to.have.property('length', 3)
          expect(c.name for c in categories).to.deep.eq([ 'bar', 'baz', 'foo' ])
