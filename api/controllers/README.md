A controller looks like this:

    module.exports =
      'get /url': (req, res, next) ->
        ... Express code returning an application/json response

      'get /url/:id': (req, res, next) ->
        ... Express code returning an application/json response

Notes:

* "Content-type: application/json" will be added to every response
* Send error objects as `next(new Error("message"))`
  * You may set `res.status(404)` or what have you prior to `next()`
