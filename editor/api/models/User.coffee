# User.js
#
# @description :: A user of the website

module.exports =
  attributes:
    username: { type: 'string' }
    email: { type: 'string' }
    passports: { collection: 'Passport', via: 'user' }
