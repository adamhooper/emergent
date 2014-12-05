Instance = require('./instance')
Promise = require('sequelize').Promise
_ = require('sequelize').Utils._

# deprecated
instanceWithTracking = (instance, email, creating, options) ->
  tracking = {}
  if creating
    tracking.createdAt = (options?.createdAt || new Date()) if 'createdAt' of instance
    tracking.createdBy = email if 'createdBy' of instance
  tracking.updatedAt = (options?.updatedAt || new Date()) if 'updatedAt' of instance
  tracking.updatedBy = email if 'updatedBy' of instance
  instance.copy(tracking)

module.exports = class Model
  constructor: (@_impl) ->
    for k, v of @_impl.options.classMethods
      @[k] = v

  # Returns an Instance
  build: (attrs) ->
    new Instance(@_impl.build(attrs))

  _trackingAttrs: (email, creating) ->
    tracking = {}
    if creating
      tracking.createdAt = (options?.createdAt || new Date()) if 'createdAt' of @_impl.attributes
      tracking.createdBy = email if 'createdBy' of @_impl.attributes
    tracking.updatedAt = (options?.updatedAt || new Date()) if 'updatedAt' of @_impl.attributes
    tracking.updatedBy = email if 'updatedBy' of @_impl.attributes
    tracking

  _formatCreateAttrs: (attrs, email) ->
    _.chain(attrs)
      .omit('id')
      .extend(@_trackingAttrs(email, true))
      .value()

  # Returns a Promise of an Instance
  create: (attrs, email, options) ->
    options = email if !options?
    if !options?.raw
      attrs = @_formatCreateAttrs(attrs, email)

    @_impl.create(attrs).then((x) -> new Instance(x))

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

  # Returns a Promise of null
  bulkCreate: (attrsArray, email) ->
    attrsArray = for attrs in attrsArray
      @_formatCreateAttrs(attrs, email)
    @_impl.bulkCreate(attrsArray)

  # Returns a Promise of number of affected rows
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

  # Returns the maximum of a column
  max: (column, options) ->
    @_impl.max(column, options)
