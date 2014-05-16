Fetches the popularity of various URLs.

Data format
===========

We store all the URLs we track in Mongo, in the `url` collection:

```javascript
var urlData = {
  "_id": new ObjectId(),
  "url": "[URL]",
  "shares": {
    "facebook": {
      "n": 3,
      "updatedAt": new Date(),
      "schedulingData": "[some internal nonsense]"
    },
    "twitter": {
      "n": 4,
      "updatedAt": new Date(),
      "schedulingData": "[some internal nonsense]"
    },
    "google": {
      "n": 1,
      "updatedAt": new Date(),
      "schedulingData": "[some internal nonsense]"
    }
  }
}
```

We also log every individual fetch in the insert-only `url_fetch` collection:

```javascript
var urlFetchData = {
  "_id": new ObjectId(),
  "url_id": new ObjectId(),
  "service": "facebook",
  "n": 3,
  "createdAt": new Date()
}
```

Scheduling
==========

When should we fetch URLs? We want to do it as frequently as possible, but we
don't want to surpass querying limits.

Initially we don't have too many URLs, so let's just say "update every URL
every two hours". Leave the `schedulingData` field empty.

We use [Kue](https://github.com/learnboost/kue) to schedule tasks in Redis.
All Redis needs to know is the URL's ObjectId, the service ("facebook",
"twitter" or "google") and how far in the future to run it.

Starting up
-----------

This service runs independently of the `truthmaker-editor`. It doesn't listen
on any port.

Because Redis is forgetful and `truthmaker-editor` does not know about the
`url` table, we have a strategy that won't scale forever but will be plenty
fast for now. On startup:

* For every `url` in the `article` collection:
  * Insert an entry in the `url` collection if it does not exist.
* For every entry in the `url` table:
  * For each service, `"facebook"`, `"twitter"` and `"google"`:
    * If there is a `shares` entry already:
      * schedule a new fetch at `updatedAt + 2 hours`
    * Otherwise
      * schedule a new fetch right now

Main loop
---------

* For every `urlId,service` tuple that `kue` gives us:
  * Fetch the URL given the urlId
  * Fetch the new count for that URL with that service
  * Add to the `url_fetch` collection
  * Update the `url` entry's `shares.[service]` entry

We do this in parallel: we can run many fetches simultaneously.
