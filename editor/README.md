A [Sails](http://sailsjs.org) application

# Architecture

The *API* is a Sails server. It responds to AJAX requests. Code is in `api/`, tests are in `test/`. This code must work with NodeJS.

The *frontend* is a Backbone.Marionette client-side application. It renders everything. Code is in `assets/js`, assets are in `test-js/`. This code must work across supported web browsers.

In between, the Sails server also serves up some basic HTML for the frontend to build upon. That's in `views/`.

We prefer CoffeeScript, but plain JavaScript shouldn't break anything.

# Installing a development environment

First, install NodeJS. Then, in this directory:

    npm install -g mocha karma-cli bower
    bower install
    npm install

# Testing

`mocha --watch` to run API tests and re-run when files change
`karma start` to run front-end tests and re-run when files change

# Developing

`sails lift` or `sails lift --verbose` will start things in development mode: it will recompile CoffeeScript and Less files as they change.

Browse to http://localhost:1337 to see the result.

You may (nay, *should*) run Mocha, Karma and Sails simultaneously when developing.
