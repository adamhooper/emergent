path = require('path')

configPath = path.resolve(__dirname, '..', 'config', 'config.json')

module.exports = require(configPath)
