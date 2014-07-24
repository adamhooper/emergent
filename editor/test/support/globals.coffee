chai = require('chai')
chaiAsPromised = require('chai-as-promised')
Q = require('q')
Promise = require('bluebird')

chai.should()
chai.use(chaiAsPromised)

Q.longStackSupport = true
Promise.longStackTraces()

global.Q = Q
global.Promise = Promise
global.expect = chai.expect
global.supertest = require('supertest')

process.env.NODE_ENV = 'test'
global.models = require('../../../data-store').models
