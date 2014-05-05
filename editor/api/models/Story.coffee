# A single news story, as defined by a curator.
#
# Many articles can be written about it.
module.exports =
  identity: 'story'

  attributes:
    slug:
      type: 'alphanumericdashed'
      required: true
      unique: true

    headline:
      type: 'string'
      required: true

    createdBy:
      type: 'email'
      required: true

    updatedBy:
      type: 'email'
      required: true

    description:
      type: 'text'

    articles:
      collection: 'article'
      via: 'stories'
      dominant: true
