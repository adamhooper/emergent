Instance = require('./instance')
_ = require('sequelize').Utils._

instanceWithTracking = (instance, email, creating) ->
  tracking = {}
  tracking.createdAt = new Date() if 'createdAt' of instance
  tracking.updatedAt = new Date() if 'updatedAt' of instance
  tracking.createdBy = email if 'createdBy' of instance
  tracking.updatedBy = email if 'updatedBy' of instance
  instance.copy(tracking)

module.exports = class Model
  constructor: (@_impl) ->

  # Returns an Instance
  build: (attrs) ->
    new Instance(@_impl.build(attrs))

  # Returns a Promise of an Instance
  create: (attrs, email) ->
    instance = @build(attrs)
    @insert(instance, email)

  # Returns a Promise of an Instance or `null`.
  find: (idOrOptions) ->
    @_impl.find(idOrOptions)
      .then((row) -> row && new Instance(row))

  # Returns a Promise of an Array of Instances
  findAll: (options) ->
    @_impl.findAll(options)
      .then((rows) -> rows.map((row) -> new Instance(row)))

  # Returns a Promise of an Array of Objects
  findAllRaw: (options) ->
    @_impl.findAll(options, raw: true)

  # Returns a Promise of the Instance
  insert: (instance, email) ->
    instance = instanceWithTracking(instance, email, true)
    instance._impl.save()
      .then(-> instance)

  # Returns a Promise of the Instance
  update: (instance, attrs, email) ->
    instance = instance.copy(attrs)
    instance = instanceWithTracking(instance, email, false)
    instance._impl.save()
      .then(-> instance)

  # Returns a Promise of the Instance
  upsert: (whereClause, instance, email) ->
    throw new Error('not implemented')

  # Returns a Promise of undefined
  destroy: (where) ->
    @_impl.destroy(where)
