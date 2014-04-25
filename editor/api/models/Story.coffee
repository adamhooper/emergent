# A single news story, as defined by a curator. Many articles can be written about it.
module.exports =
  attributes:
    slug:
      type: 'alphanumericdashed'
      required: true
      unique: true

    createdBy:
      type: 'email'
      required: true

    updatedBy:
      type: 'email'
      required: true

    description:
      type: 'text'
