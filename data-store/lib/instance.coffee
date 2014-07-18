_ = require('sequelize').Utils._

# An Instance is an _immutable_ database row.
#
# Don't modify it. Instead, call `.copy()`.
#
# Usage:
#
#     Cat = ... # a Model
#     cat = Cat.create(name: 'Jimmy', age: 4)
#     olderCat = Cat.update(cat.copy(age: 5))
module.exports = class Instance
  constructor: (@_impl) ->
    for k in @_impl.attributes
      @[k] = @_impl.get(k)

  copy: (attrs) ->
    newAttrs = _.extend({}, @_impl.get(), attrs)
    impl = @_impl.Model.build(newAttrs, isNewRecord: @_impl.isNewRecord)
    new Instance(impl)
