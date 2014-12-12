_ = require('lodash')

models = require('../../../data-store').models
Category = models.Category
CategoryStory = models.CategoryStory
Story = models.Story
StoryTag = models.StoryTag
Tag = models.Tag

AttributesWithDefaults =
  headline: ''
  description: ''
  origin: ''
  originUrl: null
  published: false
  truthiness: 'unknown'
  truthinessDate: null
  truthinessDescription: ''
  truthinessUrl: null

jsonToAttributes = (json, isCreate) ->
  ret = {}

  if isCreate
    ret.slug = json.slug

  for k, d of AttributesWithDefaults
    ret[k] = json[k] ? d

  ret

module.exports =
  index: (req, res) ->
    Promise.all([
      Story.findAll({}, raw: true)
      Category.findAll({}, raw: true)
      CategoryStory.findAll({}, raw: true)
      Tag.findAll({}, raw: true)
      StoryTag.findAll({}, raw: true)
    ])
      .spread (stories, categories, categoryStories, tags, storyTags) ->
        idToCategory = {}
        (idToCategory[c.id] = c.name) for c in categories
        idToTag = {}
        (idToTag[t.id] = t.name) for t in tags

        idToStory = {}
        for s in stories
          s.categories = []
          s.tags = []
          idToStory[s.id] = s

        for cs in categoryStories
          story = idToStory[cs.storyId]
          categoryName = idToCategory[cs.categoryId]
          if story? && categoryName?
            story.categories.push(categoryName)

        for st in storyTags
          story = idToStory[st.storyId]
          tagName = idToTag[st.tagId]
          if story? && tagName?
            story.tags.push(tagName)

        for s in stories
          s.categories.sort((a, b) -> a.localeCompare(b))
          s.tags.sort((a, b) -> a.localeCompare(b))

        stories
      .then (val) -> res.json(val)
      .catch (err) -> res.status(500).json(err)

  find: (req, res) ->
    slug = req.param('slug') || ''
    models.sequelize.query("""
      SELECT
        s."id",
        s."slug",
        s."headline",
        s."description",
        s."createdAt",
        s."createdBy",
        s."updatedAt",
        s."updatedBy",
        s."origin",
        s."originUrl",
        s."truthiness",
        s."truthinessDate",
        s."truthinessDescription",
        s."truthinessUrl",
        s."published",
        (
          SELECT COALESCE(ARRAY_AGG(c."name"), ARRAY[]::VARCHAR[])
          FROM "Category" c
          INNER JOIN "CategoryStory" cs ON c.id = cs."categoryId"
          WHERE cs."storyId" = s."id"
        ) AS "categories",
        (
          SELECT COALESCE(ARRAY_AGG(t."name"), ARRAY[]::VARCHAR[])
          FROM "Tag" t
          INNER JOIN "StoryTag" st ON t.id = st."tagId"
          WHERE st."storyId" = s."id"
        ) AS "tags"
      FROM "Story" s
      WHERE s."slug" = ?
    """, null, { raw: true }, [ slug ])
      .then (arr) -> arr[0]
      .then (val) ->
        if val?
          res.json(val)
        else
          res.status(404).json(message: "Could not find a story with slug '#{slug}'")
      .catch (err) -> res.status(400).json(err)

  create: (req, res) ->
    if !req.body?
      res.status(400).json(message: 'You must send the JSON properties to create')
    else
      attributes = jsonToAttributes(req.body, true)
      categories = _.toArray(req.body.categories) || []
      Promise.all([
        Story.create(attributes, req.user.email)
        Category.findAll(where: { name: categories })
      ])
        .spread (story, categories) ->
          attrsArray = for category in categories
            storyId: story.id, categoryId: category.id
          CategoryStory.bulkCreate(attrsArray, req.user.email)
            .then -> [ story, categories ]
        .spread (story, categories) ->
          _.extend(story.toJSON(), categories: _.pluck(categories, 'name'))
        .then (val) -> res.json(val)
        .catch (err) -> res.status(400).json(err)

  destroy: (req, res) ->
    slug = req.param('slug') || ''
    # The ON DELETE CASCADE on the foreign key automatically destroys
    # CategoryStory and Article children.
    Story.destroy(slug: slug)
      .then -> models.sequelize.query('DELETE FROM "Tag" t WHERE NOT EXISTS (SELECT 1 FROM "StoryTag" WHERE "tagId" = t.id)')
      .then -> res.json({})
      .catch (err) -> res.status(500).json(err)

  update: (req, res) ->
    slug = req.param('slug') || ''
    if !req.body?
      res.status(400).json(message: 'You must send the JSON properties to update')
    else
      attributes = jsonToAttributes(req.body, false)
      categories = _.toArray(req.body.categories) || []
      Promise.all([
        Story.find(where: { slug: slug })
        Category.findAll(where: { name: categories })
      ])
        .spread (story, wantedCategories) ->
          if !story
            res.status(404).json(message: "Could not find a story with slug '#{slug}'")
          else
            wantedCategoryIds = (c.id for c in wantedCategories)
            wantedCategoryNames = (c.name for c in wantedCategories)
            wantedCategoryStories = for wantedCategory in wantedCategories
              { storyId: story.id, categoryId: wantedCategory.id }

            deleteWhere = { storyId: story.id }
            if wantedCategoryIds.length
              deleteWhere.categoryId = { not: wantedCategoryIds }
            Promise.all([
              Story.update(story, attributes, req.user.email)
              CategoryStory.destroy(deleteWhere)
              Promise.map(wantedCategoryStories, (cs) -> CategoryStory.upsert(cs, req.user.email))
            ])
              .spread (story, __, categoryStories) ->
                json = _.extend(story.toJSON(), categories: wantedCategoryNames)
                res.json(json)
        .catch (err) -> res.status(500).json(err)
