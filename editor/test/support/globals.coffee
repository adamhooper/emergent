chai = require('chai')
chaiAsPromised = require('chai-as-promised')
Q = require('q')

chai.should()
chai.use(chaiAsPromised)

Q.longStackSupport = true

global.Q = Q
global.supertest = require('supertest')
