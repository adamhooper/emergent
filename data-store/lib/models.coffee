fs = require('fs')
Sequelize = require('sequelize')
_ = Sequelize.Utils._

Model = require('./model')
env = process.env.NODE_ENV || 'development'
options = require('./config')[env]

options.logging &&= console.log

sequelize = new Sequelize(options.database, options.username, options.password, options)

SequelizeModelOptions =
  timestamps: false
  freezeTableName: true

IdColumn =
  id:
    type: Sequelize.UUID
    allowNull: false
    primaryKey: true
    defaultValue: Sequelize.UUIDV1

for codeFile in fs.readdirSync("#{__dirname}/schema")
  modelName = codeFile.split(/\./)[0]
  schema = require("#{__dirname}/schema/#{modelName}")

  modelImpl = sequelize.define(
    modelName,
    _.extend({}, IdColumn, schema),
    SequelizeModelOptions
  )

  module.exports[modelName] = new Model(modelImpl)

module.exports.Sequelize = Sequelize
module.exports.sequelize = sequelize
