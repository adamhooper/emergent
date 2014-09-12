chai = require('chai')
chaiAsPromised = require('chai-as-promised')
Promise = require('bluebird')

chai.should()
chai.use(chaiAsPromised)

Promise.longStackTraces()
Promise.onPossiblyUnhandledRejection(->) # FIXME can we remove this?

global.Promise = Promise
global.expect = chai.expect
