f = (url, done) ->
  f.request.get "https://graph.facebook.com/v2.0/#{encodeURIComponent(url)}?access_token=#{encodeURIComponent(f.access_token)}", (err, resp, body) ->
    return done(err) if err?

    data = JSON.parse(body)
    done(null, n: data.shares || 0)

f.request = require('request')

module.exports = f
