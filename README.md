There's a lot to do. No time to write about it.

# Install

First, install NodeJS. Then, in this directory:

    npm install -g mocha karma-cli bower supervisor
    (cd data-store && npm install)
    (cd editor && npm install)
    (cd url-fetcher && npm install)
    (cd viewer && npm install)
    (cd editor && bower install)

Next, install `redis-server` and `postgresql`.

Run the following for Postgres:

    createuser truthmaker
    createdb truthmaker_test -O truthmaker
    createdb truthmaker_dev -O truthmaker
    createdb truthmaker -O truthmaker

Set up the database schema like so:

    (cd data-store && bin/sequelize db:migrate)
    (cd data-store && NODE_ENV=production bin/sequelize db:migrate)
    # truthmaker_test database will be migrated automatically

# Run

Read the `README` file for each component to see how to run it.

You can run any or all components at once. You may start or stop them
in any order.

# Deploy

Set up `truthmaker` as a git remote and run `deploy/deploy`.

# Components

* `editor`: interface for editors to add Stories and Articles.
* `url-fetcher`: handles popularity and article content in the background.
* `viewer`: visualizations, for end-users.

Licence: proprietary
