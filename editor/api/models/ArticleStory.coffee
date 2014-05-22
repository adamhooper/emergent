# A many-to-many association between Article and Story.
#
# (Why not use Waterline associations? Because
# https://github.com/balderdashy/waterline/issues/438 )
module.exports =
  identity: 'article_story'

  attributes:
    articleId:
      type: 'objectid'
      required: true

    storyId:
      type: 'objectid'
      required: true
