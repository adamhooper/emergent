redis = require('redis')

module.exports = class JobQueue
  constructor: (options) ->
    throw 'Must set options.key, a Redis List key' if !options?.key
    @_key = options.key

    @client = redis.createClient()

  quit: (done) -> @client.quit(done)

  clear: (done) -> @client.del(@_key, done)

  # Queues a job. Listen for it using dequeue().
  queue: (job, done) -> @client.rpush(@_key, JSON.stringify(job), done)

  # Returns the next job but leaves it intact. Returns null on empty.
  peek: (done) ->
    @client.lrange @_key, 0, 0, (err, val) ->
      if !err?
        if val.length > 0
          val = JSON.parse(val[0])
        else
          val = null
      done(err, val)

  # Returns the next job. Waits for one to appear, if there is none.
  dequeue: (done) ->
    @client.blpop @_key, 0, (err, val) ->
      val = JSON.parse(val[1]) if !err?
      done(err, val)
