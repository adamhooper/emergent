A [Sails](http://sailsjs.org) application

# Architecture

The *API* is a Sails server. It responds to AJAX requests. Code is in `api/`, tests are in `test/`. This code must work with NodeJS.

The *frontend* is a Backbone.Marionette client-side application. It renders everything. Code is in `assets/js`, assets are in `test-js/`. This code must work across supported web browsers.

In between, the Sails server also serves up some basic HTML for the frontend to build upon. That's in `views/`.

We prefer CoffeeScript, but plain JavaScript shouldn't break anything.

# Testing

`karma start` to run front-end tests
`mocha` to run API tests
