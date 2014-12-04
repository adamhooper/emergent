fs = require('fs')
Sequelize = require('sequelize')
_ = Sequelize.Utils._

Model = require('./model')
env = process.env.NODE_ENV || 'development'
options = require('./config')[env]

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

  columns = if schema.columns.id == undefined
    _.extend({}, IdColumn, schema.columns)
  else
    _.omit(schema.columns, 'id')

  nonColumns = {}
  nonColumns[k] = v for k, v of schema when k != 'columns'

  modelImpl = sequelize.define(
    modelName,
    columns,
    _.extend({}, SequelizeModelOptions, nonColumns)
  )

  module.exports[modelName] = new Model(modelImpl)

module.exports.Sequelize = Sequelize
module.exports.sequelize = sequelize
