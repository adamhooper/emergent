module.exports = {
  // One class per model
  models: require('./lib/models'),

  // A function that returns a Promise, resolved when the database schema is up to date
  migrate: require('./lib/migrate')
};
