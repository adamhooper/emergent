Sequelize = require('sequelize')

# Something on the Internet.
#
# A Url is just a web address; we store the stuff we find there in UrlGets and
# we store the info we parse from those in UrlVersions.
module.exports =
  columns:
    url:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate: { isUrl: true }
