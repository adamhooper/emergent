module.exports =
  up: (migration, DataTypes, done) ->
    migration.createTable('User', {
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      email:
        type: DataTypes.STRING
        allowNull: false
        validate: { isEmail: true }
        unique: true
    }).nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.dropTable('User').nodeify(done)
