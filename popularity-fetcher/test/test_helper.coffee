chai = require('chai')
chaiAsPromised = require('chai-as-promised')
sinon = require('sinon')
sinonChai = require('sinon-chai')
Q = require('q')

chai.should()
chai.use(chaiAsPromised)
chai.use(sinonChai)

Q.longStackSupport = true

global.Q = Q
global.sinon = sinon
global.expect = chai.expect
