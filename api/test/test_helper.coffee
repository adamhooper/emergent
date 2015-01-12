process.env.NODE_ENV = 'test'

chai = require('chai')
chaiAsPromised = require('chai-as-promised')
supertest = require('supertest')

chai.use(chaiAsPromised)

global.Promise = require('bluebird')
global.expect = chai.expect
global.models = require('../../data-store').models

global.app = app = require('../app')

api = supertest(app)
promiseApi = (method) ->
  (args...) ->
    req = api[method](args...)
    Promise.promisify(req.end, req)()

global.api =
  get: promiseApi('get')
  head: promiseApi('head')
  post: (path, json) ->
    req = api.post(path)
      .set('Accept', 'application/json')
      .send(json)
    Promise.promisify(req.end, req)()
