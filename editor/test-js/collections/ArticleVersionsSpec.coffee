define [
  'collections/ArticleVersions'
  'models/ArticleVersion'
], (ArticleVersions, ArticleVersion) ->
  describe 'collections/ArticleVersions', ->
    beforeEach ->
      @subject = new ArticleVersions([], articleId: '140ecdf4-0676-4720-9025-12be0e0ddc9e')

    it 'should have the proper url', ->
      expect(@subject.url()).to.equal('/articles/140ecdf4-0676-4720-9025-12be0e0ddc9e/versions')

    it 'should contain ArticleVersions', ->
      @subject.add({})
      expect(@subject.at(0)).to.be.an.instanceOf(ArticleVersion)
