# Chooses a time to schedule tasks.
#
# For instance:
#
# ```coffee
# chooser = new TaskTimeChooser(delays: [
#   0    # first invocation comes right away
#   7200 # second invocation happens two minutes after chooseTime() is called
#   3600 # third invocation happens one minute after chooseTime() is called
# ])
#
# chooser.chooseTime(1, new Date()) # chooses two minutes in the future
# chooser.guessNPreviousInvocations(lastInvocationDate, firstInvocationDate) # returns a Number
# ```
FIXME CODE guessNPreviousInvocations
module.exports = class TaskTimeChooser
  constructor: (options) ->
    throw 'Must pass options.delays, an Array of Numbers representing milliseconds' if !options.delays
    @delays = options.delays

  chooseTime: (nPreviousInvocations, lastInvocationTime) ->
    if (delay = @delays[nPreviousInvocations])?
      lastInvocationTime ?= new Date()
      new Date(lastInvocationTime.valueOf() + delay)
    else
      null
