define [
  'models/ArticleVersion'
], (ArticleVersion) ->
  describe 'models/ArticleVersion', ->
    beforeEach ->
      @subject = new ArticleVersion({})
      @subject.collection =
        url: -> '/articles/140ecdf4-0676-4720-9025-12be0e0ddc9e/versions'

    it 'should have the proper #create url', ->
      expect(@subject.url()).to.eq('/articles/140ecdf4-0676-4720-9025-12be0e0ddc9e/versions')

    it 'should have the proper #update url', ->
      @subject.set(id: '140ecdf4-0676-4720-9025-12be0e0ddc9f')
      expect(@subject.url()).to.eq('/articles/140ecdf4-0676-4720-9025-12be0e0ddc9e/versions/140ecdf4-0676-4720-9025-12be0e0ddc9f')
