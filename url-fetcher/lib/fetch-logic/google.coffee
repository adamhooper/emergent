f = (url, done) ->
  f.request.post {
    url: 'https://clients6.google.com/rpc'
    body: [{"method":"pos.plusones.get","id":"p","params":{"nolog":true,"id":url,"source":"widget","userId":"@viewer","groupId":"@self"},"jsonrpc":"2.0","key":"p","apiVersion":"v1"}]
    json: true
  }, (err, resp, body) ->
    return done(err) if err?

    n = body?[0]?.result?.metadata?.globalCounts?.count || 0

    done(null, n: n, rawData: body)

f.request = require('request')

module.exports = f
