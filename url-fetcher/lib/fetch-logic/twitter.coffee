f = (url, done) ->
  f.request.get "https://cdn.api.twitter.com/1/urls/count.json?url=#{encodeURIComponent(url)}", (err, resp, body) ->
    return done(err) if err?

    data = JSON.parse(body)
    done(null, n: data.count || 0)

f.request = require('request')

module.exports = f
