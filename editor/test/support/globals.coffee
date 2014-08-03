chai = require('chai')
chaiAsPromised = require('chai-as-promised')
Promise = require('bluebird')

chai.should()
chai.use(chaiAsPromised)

Promise.longStackTraces()
Promise.onPossiblyUnhandledRejection(->) # FIXME can we remove this?

global.Promise = Promise
global.expect = chai.expect
global.supertest = require('supertest')

process.env.NODE_ENV = 'test'
global.models = require('../../../data-store').models
