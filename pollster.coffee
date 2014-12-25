`import Ember from 'ember'`

Pollster = Ember.Object.extend
  # Time between polls (in ms)
  interval: (->
    5000
  ).property()
  
  # Max number of polls
  maxPolls: (->
    3
    ).property()

  # Schedules the function `f` to be executed every `interval` time.
  schedule: (f) ->
    Ember.run.later @, (->
      iteration = @get "iteration"
      if iteration < @get("maxPolls")
        f.apply @
        @set "iteration", iteration+1
        @set "timer", @schedule(f)
      else
        @stop()
      return
    ), @get("interval")

  
  # Stops the pollster
  stop: ->
    Ember.run.cancel @get("timer")
    @set "iteration", 0
    @set "timer", null
    return
  
  # Starts the pollster, i.e. executes the `onPoll` function every interval.
  start: ->
    @set "iteration", 0
    unless @get("timer")
      @set "timer", @schedule(@get("onPoll"))
    return

  # Method should be set on Pollster.create 
  onPoll: ->

`export default Pollster`
