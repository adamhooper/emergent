A [Sails](http://sailsjs.org) application

# Architecture

The *API* is a Sails server. It responds to AJAX requests. Code is in `api/`, tests are in `test/`. This code must work with NodeJS.

The *frontend* is a Backbone.Marionette client-side application. It renders everything. Code is in `assets/js`, assets are in `test-js/`. This code must work across supported web browsers.

In between, the Sails server also serves up some basic HTML for the frontend to build upon. That's in `views/`.

We prefer CoffeeScript, but plain JavaScript shouldn't break anything.

# Installing a development environment

First, install NodeJS. Then, in this directory:

    npm install -g mocha karma-cli bower supervise
    bower install
    npm install

# Testing

`mocha --watch` to run API tests and re-run when files change
`karma start` to run front-end tests and re-run when files change

# Developing

In one terminal, run `gulp`. This will recompile the assets as they change.

In another terminal, run `supervise index.coffee`. This will run the server
and restart it when any files change.

Browse to http://localhost:1337 to see the result.

You may (nay, *should*) run Mocha, Karma and Sails simultaneously when
developing.

# Deploying

Run `gulp prod` to compile assets. (This can whir for a minute.)

Run `coffee index.coffee` (or `npm start`). This will run the server.
