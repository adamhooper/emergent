module.exports = 
  up: (migration, DataTypes, done) ->
    q = (s) -> migration.migrator.sequelize.query(s)

    migration.createTable('UserSubmittedClaim', {
      id:
        type: DataTypes.UUID
        allowNull: false
        primaryKey: true
        defaultValue: DataTypes.UUIDV1

      createdAt:
        type: DataTypes.DATE
        allowNull: false

      requestIp:
        type: 'INET'
        allowNull: false

      claim:
        type: DataTypes.STRING(1024)
        allowNull: false

      url:
        type: DataTypes.STRING(1024)
        allowNull: false

      spam:
        type: DataTypes.BOOLEAN
        allowNull: false

      archived:
        type: DataTypes.BOOLEAN
        allowNull: false

      urlId:
        type: DataTypes.UUID
        allowNull: true
    })
      .then(-> q("""
        CREATE INDEX "user_submitted_claim_to_track"
        ON "UserSubmittedClaim" (id)
        WHERE "urlId" IS NULL AND spam = FALSE
      """))
      .then(-> q("""
        CREATE INDEX "user_submitted_claim_inbox"
        ON "UserSubmittedClaim" (id)
        WHERE spam = FALSE AND archived = FALSE
      """))
      .then(-> q("""
        CREATE INDEX "user_submitted_claim_url_id"
        ON "UserSubmittedClaim" ("urlId")
      """))
      .then(-> q("""
        ALTER TABLE "UserSubmittedClaim"
        ADD FOREIGN KEY ("urlId") REFERENCES "Url" (id)
        ON DELETE SET NULL
      """))
      .nodeify(done)

  down: (migration, DataTypes, done) ->
    migration.dropTable('UserSubmittedClaim')
      .nodeify(done)
