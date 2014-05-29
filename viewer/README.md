Setup
-----

    npm install
    npm -g install node-dev

Running
-------

    node-dev app.coffee # in one terminal
    node_modules/.bin/gulp --require coffee-script/register # in another terminal

Deploying
---------

    node_modules/.bin/gulp --require coffee-script/register prod # compile assets
    # ... and run app.coffee
