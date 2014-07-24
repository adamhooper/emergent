Sequelize = require('sequelize')

# A person with special permissions.
module.exports =
  columns:
    email:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate: { isEmail: true }
