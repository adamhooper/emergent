module.exports.passport =
  google:
    name: 'Google'
    protocol: 'openid'
    strategy: require('passport-google').Strategy
