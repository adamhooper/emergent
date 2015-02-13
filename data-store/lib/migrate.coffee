Sequelize = require('sequelize')
Umzug = require('umzug')

# Returns a Promise, fulfilled when all migrations are applied
module.exports = ->
  sequelize = require('./models').sequelize

  # Umzug is mean. It requires a _resolved_ Sequelize instead of plain ol'
  # `sequelize` or a parameter. That won't work for us, because our callers
  # don't depend on Sequelize.
  #
  # So .... chdir! Yup, seriously.
  cwd = process.cwd()

  try
    process.chdir("#{__dirname}/..")

    umzug = new Umzug
      storage: 'sequelize'
      storageOptions: { sequelize: sequelize }
      logging: console.log
      migrations:
        params: [ sequelize.getQueryInterface(), Sequelize ]
        path: __dirname + '/../migrations'
        pattern: /\.(coffee|js)$/
        wrap: (fun) ->
          if fun.length == 3
            return Sequelize.Promise.promisify(fun)
          else
            return fun

    umzug.up()

  finally
    process.chdir(cwd)
