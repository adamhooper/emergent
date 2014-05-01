define [ 'models/Story' ], (Story) ->
  describe 'models/Story', ->
    beforeEach ->
      @subject = new Story(slug: 'a-slug')

    it 'should have id = slug', ->
      expect(@subject.id).to.equal('a-slug')
