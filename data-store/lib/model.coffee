Instance = require('./instance')
Promise = require('sequelize').Promise
_ = require('sequelize').Utils._

instanceWithTracking = (instance, email, creating, options) ->
  tracking = {}
  tracking.createdAt = (options?.createdAt || new Date()) if 'createdAt' of instance
  tracking.updatedAt = (options?.updatedAt || new Date()) if 'updatedAt' of instance
  tracking.createdBy = email if 'createdBy' of instance
  tracking.updatedBy = email if 'updatedBy' of instance
  instance.copy(tracking)

module.exports = class Model
  constructor: (@_impl) ->
    for k, v of @_impl.options.classMethods
      @[k] = v

  # Returns an Instance
  build: (attrs) ->
    new Instance(@_impl.build(attrs))

  # Returns a Promise of an Instance
  create: (attrs, email, options={}) ->
    delete attrs.id

    options = email if _.isObject(email)

    if !options.raw
      delete attrs.createdAt
      delete attrs.updatedAt
      delete attrs.createdBy
      delete attrs.updatedBy

    instance = @build(attrs)
    if !options.raw
      instance = instanceWithTracking(instance, email, true, options)
    instance._impl.save(null, options)

  # Returns a Promise of an Instance or `null`.
  find: (idOrOptions) ->
    @_impl.find(idOrOptions)
      .then((row) -> row && new Instance(row))

  # Returns a Promise of an Array of Instances
  findAll: (options, queryOptions) ->
    ret = @_impl.findAll(options, queryOptions)

    if !queryOptions?.raw
      ret = ret.then((rows) -> new Instance(row) for row in rows)

    ret

  # Returns a Promise of an Array of Objects
  findAllRaw: (options) ->
    @_impl.findAll(options, raw: true)

  # Returns a Promise of the Instance
  update: (instance, attrs, email) ->
    instance = instance.copy(attrs)
    instance = instanceWithTracking(instance, email, false)
    instance._impl.save()
      .then(-> instance)

  # Returns a Promise
  bulkUpdate: (attrs, where, email, options) ->
    attrs = _.extend({}, attrs)
    attrs.updatedAt = new Date() if 'updatedAt' of @_impl.attributes
    attrs.updatedBy = email if 'updatedBy' of @_impl.attributes

    @_impl.update(attrs, where, options)

  # Returns a Promise of [Instance, isNew].
  #
  # An upsert will insert a new row if an insert fails because of a conflict.
  #
  # It won't handle a race in which the instance is deleted after the INSERT
  # but before the SELECT.
  upsert: (instance, email) ->
    @create(instance, email)
      .then((x) -> [ x, true ])
      .catch (e) =>
        if (e.code == 'SQLITE_CONSTRAINT' && e.errno == 19) || (e.severity == 'ERROR' && e.code == '23505')
          uniqueCols = (col for col, props of @_impl.attributes when props.unique)
          where = {}
          (where[col] = instance[col]) for col in uniqueCols
          @find(where: where)
            .then((x) -> [ x, false ])
        else
          Promise.reject(e)

  # Returns a Promise of undefined
  destroy: (where) ->
    @_impl.destroy(arguments...)
