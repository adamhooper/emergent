Sequelize = require('sequelize')

# Something on the Internet.
#
# A Url is just a web address; we store the stuff we find there in UrlGets and
# we store the info we parse from those in UrlVersions.
module.exports =
  url:
    type: Sequelize.STRING
    allowNull: false
    validate: { isUrl: true }
