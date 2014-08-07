Promise = require('bluebird')
chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')

chai.should()
chai.use(sinonChai)

Promise.longStackTraces()
Promise.onPossiblyUnhandledRejection(->) # FIXME can we remove this?

global.Promise = Promise
global.sinon = sinon
global.expect = chai.expect
