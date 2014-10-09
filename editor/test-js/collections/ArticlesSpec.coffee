Articles = require('../../assets/js/collections/Articles')
Article = require('../../assets/js/models/Article')

describe 'collections/Articles', ->
  describe 'with a storySlug', ->
    beforeEach ->
      @collection = new Articles([])
      @collection.storySlug = 'a-slug'

    it 'should have the proper url', -> expect(@collection.url()).to.equal('/stories/a-slug/articles')
    it 'should contain Articles', ->
      @collection.add({})
      expect(@collection.at(0)).to.be.an.instanceOf(Article)
