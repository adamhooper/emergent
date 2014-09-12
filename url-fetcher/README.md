Fetches the popularity of various URLs.

This service runs independently of the `truthmaker-editor`. It doesn't listen
on any port.

Data format
===========

This program connects to Postgres, reads from `Url` and writes to `UrlGet`,
`UrlPopularityGet`, `UrlVersion` and `ArticleVersion`.

Scheduling
==========

When should we fetch URLs? We want to do it as frequently as possible, but we
don't want to surpass querying limits.

Initially we don't have too many URLs, so let's just say "update every URL
every hour".

We use a simple Redis list to inform this program when a new row has been added
to the `Url` table. The list contains rows in JSON format.
