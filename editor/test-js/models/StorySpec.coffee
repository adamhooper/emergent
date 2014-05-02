define [ 'models/Story' ], (Story) ->
  describe 'models/Story', ->
    describe 'with a new Story', ->
      beforeEach -> @subject = new Story({ slug: 'a-slug' }, isNew: true)
      it 'should have id = slug', -> expect(@subject.id).to.equal('a-slug')
      it 'should have isNew = true', -> expect(@subject.isNew()).to.equal(true)
      it 'should have isNew = false after sync', ->
        @subject.sync = ->
        @subject.save()
        expect(@subject.isNew()).to.equal(false)

    describe 'with a Story from the server', ->
      beforeEach -> @subject = new Story(slug: 'a-slug')
      it 'should have id = slug', -> expect(@subject.id).to.equal('a-slug')
      it 'should have isNew = false', -> expect(@subject.isNew()).to.equal(false)
