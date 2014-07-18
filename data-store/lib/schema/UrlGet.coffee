Sequelize = require('sequelize')

# An HTTP response from a GET of the give URL.
#
# Every Url has a number of UrlGet objects: one per GET request of that URL.
# (Truthmaker will poll with a GET request every once in a while to monitor
# articles for changes.)
#
# These are immutable. They're pretty big, too. Postgres will compress the body
# (it'll be a TOAST column), but even compressed, some URLs will take 20kb a
# pop.
module.exports =
  urlId:
    type: Sequelize.INTEGER
    references: 'Url'
    reterencesKey: 'id'

  createdAt:
    type: Sequelize.DATE
    allowNull: false
    defaultValue: Sequelize.NOW

  statusCode:
    type: Sequelize.INTEGER
    allowNull: false

  responseHeaders:
    # JSON
    type: Sequelize.TEXT
    allowNull: false

    get: -> JSON.parse(@getDataValue('responseHeaders'))
    set: (v) -> @setDataValue(JSON.stringify(v))

  body:
    type: Sequelize.TEXT
    allowNull: false
