$ = require('jquery')
Backbone = require('backbone')
Backbone.$ = $

Promise = require('bluebird')
chai = require('chai')
sinon = require('sinon')
sinonChai = require('sinon-chai')

global.jQuery = $ # for chai-jquery
chaiJquery = require('chai-jquery')

chai.use(sinonChai)
chai.use(chaiJquery)

Promise.longStackTraces()
Promise.onPossiblyUnhandledRejection(->)

global.Promise = Promise
global.sinon = sinon
global.expect = chai.expect
