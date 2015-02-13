Instance = require('./instance')
Promise = require('sequelize').Promise
Sequelize = require('sequelize')
_ = require('sequelize').Utils._

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
      tracking.createdAt = new Date() if 'createdAt' of @_impl.attributes
      tracking.createdBy = email if 'createdBy' of @_impl.attributes
    tracking.updatedAt = new Date() if 'updatedAt' of @_impl.attributes
    tracking.updatedBy = email if 'updatedBy' of @_impl.attributes
    tracking

  _formatCreateAttrs: (attrs, email) ->
    _.chain(attrs)
      .omit('id')
      .defaults(@_trackingAttrs(email, true))
      .value()

  _formatUpdateAttrs: (attrs, email) ->
    _.chain(attrs)
      .omit('id')
      .defaults(@_trackingAttrs(email, false))
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
    attrs = @_formatUpdateAttrs(attrs, email)
    instance = instance.copy(attrs)
    instance._impl.save()
      .then(-> instance)

  # Returns a Promise of null
  bulkCreate: (attrsArray, email) ->
    attrsArray = for attrs in attrsArray
      @_formatCreateAttrs(attrs, email)
    @_impl.bulkCreate(attrsArray)

  # Returns a Promise of number of affected rows
  bulkUpdate: (attrs, where, email, options) ->
    attrs = @_formatUpdateAttrs(attrs, email)
    options = _.extend({ where: where }, options)

    @_impl.update(attrs, options)
      .then((res) -> res[0])

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
        if e instanceof Sequelize.UniqueConstraintError
          uniqueCols = (col for col, props of @_impl.attributes when props.unique)
          where = {}
          (where[col] = instance[col]) for col in uniqueCols
          @find(where: where)
            .then((x) -> [ x, false ])
        else
          Promise.reject(e)

  # Returns a Promise of undefined
  #
  # Usage: Model.destroy(where: { foo: 'bar' })
  destroy: (options) ->
    options ||= {}
    if !options.where && !options.truncate
      options = _.extend({ where: '1=1' }, options)
    @_impl.destroy(options)

  # Returns the maximum of a column
  max: (column, options) ->
    @_impl.max(column, options)
