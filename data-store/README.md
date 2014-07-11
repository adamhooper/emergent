Truthmaker data model
=====================

Read `lib/schema/*.coffee` to understand the database schema.

But how do we interface with it? Through Stores and Models.

Schemas
-------

Schemas are used to define how Models are created.

All Schemas have an implicit primary key:

```coffeescript
id:
  type: DataTypes.UUID
  primaryKey: true
  defaultValue: DataTypes.UUIDV1
```

Models
------

A Model mirrors a database row. It behaves like a plain JavaScript object. It
is _immutable_.

Some Models have special accessor methods to grok what's in the database.

Stores
------

A Store is a factory for Models. It creates them by reading from and/or writing
to the database.

Like this:

```coffeescript
ArticleVersionStore = require('truthmaker-data-model').stores.ArticleVersionStore

# Get a Promise of an ArticleVersion
v1 = ArticleVersionStore.findOne(id: ...)

# Get a Promise of a modified ArticleVersion
updatedV1 = ArticleVersionStore.update(v1, { truthiness: 'myth' }, 'adam@adamhooper.com')

# Log the new object
updatedV1.then(console.log, console.warn)
```

Paper trail
-----------

All inserts and updates take the email address of the person making the change.
This will auto-populate any `createdAt`, `createdBy`, `updatedAt` and
`updatedBy` fields before saving. When Truthmaker writes on its own, its email
address is `null`.
