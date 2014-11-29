Sequelize = require('sequelize')

# A Tag: something to group stories.
#
# You can calculate tags counts by joining the StoryTag table.
#
# In the data model, there is no difference between tags and categories. As far
# as administrators are concerned, there is: tags can be created on-the-fly but
# categories must be created in a special UI. (The reason: categories have
# prominence in the UI, so we don't want spurious ones.)
module.exports =
  columns:
    name:
      type: Sequelize.STRING
      allowNull: false
      unique: true
