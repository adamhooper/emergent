JobQueue = require('../lib/JobQueue')

describe 'JobQueue', ->
  beforeEach ->
    @job1 = { id: 'e8e13e59-83b2-40ff-b13f-5e6f4825e748', url: 'http://example.org/1' }
    @job2 = { id: '440d2c9d-c4f4-4482-97fd-ac82387820e0', url: 'http://example.org/2' }

    @key = 'JobQueueTest'
    @writer = new JobQueue(key: @key)
    @reader = new JobQueue(key: @key)

  afterEach (done) ->
    @writer.clear (err1) =>
      @writer.quit (err2) =>
        @reader.quit (err3) ->
          done(err1 || err2 || err3 || null)

  describe '#queue', ->
    it 'should add a job to the queue', (done) ->
      @writer.queue @job1, (err) =>
        expect(err).to.be.null
        @writer.peek (err, item) =>
          expect(item).to.deep.eq(@job1)
          done(err)

    it 'should queue the first job before the second', (done) ->
      @writer.queue @job1, (err) =>
        @writer.queue @job2, (err) =>
          expect(err).to.be.null
          @writer.peek (err, item) =>
            expect(err).to.be.null
            expect(item).to.deep.eq(@job1)
            done(err)

  describe '#clear', ->
    it 'should clear the queue', (done) ->
      @writer.queue @job1, =>
        @writer.clear (err) =>
          expect(err).to.be.null
          @writer.peek (err, val) ->
            expect(val).to.be.null
            done(err)

  describe '#peek', ->
    it 'should return null when there is nothing in the queue', (done) ->
      @writer.peek (err, item) =>
        expect(err).to.be.null
        expect(item).to.be.null
        done(err)

  describe '#dequeue', ->
    it 'should return an item', (done) ->
      @writer.queue @job1, =>
        @reader.dequeue (err, item) =>
          expect(err).to.be.null
          expect(item).to.deep.eq(@job1)
          done(err)

    it 'should wait until an item is added', (done) ->
      @reader.dequeue (err, item) =>
        expect(err).to.be.null
        expect(item).to.deep.eq(@job1)
        done(err)
      setTimeout((=> @writer.queue(@job1)), 0)
