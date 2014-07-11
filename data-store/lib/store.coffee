class Store
  constructor: (@klass) ->

  # Returns a Promise of an Instance
  create: (attrs) -> @klass.create(attrs)

  # Returns a Promise of the Instance
  insert: (model) -> model._impl.save()

  # Returns a Promise of the Instance
  update: (model) -> model._impl.save()

  # Returns a Promise of the Instance
  upsert: (whereClause, model) -> throw new Error('not implemented')

  # Returns a Promise of null
  destroy: (model) -> model._impl.destroy()
