Store = require('./store')
fs = require('fs')

for codeFile in fs.readDirSync("#{__dirname}/models")
  modelName = codeFile.split(/\./)[0]
  model = require("#{__dirname}/models/#{modelName}")

  module.exports[modelName] = new Store(model)
