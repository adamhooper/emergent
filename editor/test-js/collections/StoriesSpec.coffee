define [ 'collections/Stories', 'models/Story' ], (Stories, Story) ->
  describe 'collections/Stories', ->
    beforeEach ->
      @subject = new Stories()

    it 'should contain Stories', ->
      @subject.push(slug: 'a-slug')
      expect(@subject.at(0)).to.be.an.instanceOf(Story)
