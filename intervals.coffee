###

  Intervals - save curr time to localStorage
             check if already more by time in minutes
             then previous saved time

###

`import Ember from 'ember'`


Intervals = Ember.Object.extend
  intervalNames: 'intervalNames'

  'new': (name, timeout) ->
    interval = Interval.create({name: name, timeout: timeout})
    @addToList(name)
    Ember.set(@, name, interval)
    return interval

  addToList: (name) ->
    addToIntervals(name)
    return @

  clear: ->
    clearAllIntervals()
    return @

  reset: ->
    names = window.localStorage.getItem(@intervalNames)
    return @ unless names
    names.split(',').forEach (name) =>
      interval = @get(name)
      if interval
        interval.reset()
    return @


###

  private struct

###

intervalNames = 'intervalNames'

Interval = Ember.Object.extend
  name: null
  timeout: 1800

  unixtime: ->
    Date.parse(new Date())/1000

  unixToDate: (unixtime) ->
    new Date(unixtime*1000)

  reset: ->
    window.localStorage.setItem(@name, @unixtime())
    return @

  load: ->
    Number(window.localStorage.getItem(@name))

  clear: ->
    clear(@name)
    return @

  clearAll: ->
    clearAllIntervals()
    return @

  addToList: ->
    addToIntervals(@name)
    return @

  check: ->
    savedTime = @load()
    return false unless savedTime
    unixtime = @unixtime()
    return (savedTime + @timeout <= unixtime) or @checkDays(savedTime, unixtime)

  checkDays: (date1, date2) ->
    @unixToDate(date1).getDate() isnt @unixToDate(date2).getDate()


###
  remove record from localstorage by name
###
clear = (name) ->
  window.localStorage.removeItem(name)

###
  add to intervals names list other name
###
addToIntervals = (name) ->
  savedNames = window.localStorage.getItem(intervalNames)
  names = if savedNames then savedNames.split(',') else []
  return if names.indexOf(name) > -1
  names.push(name)
  window.localStorage.setItem(intervalNames, names.join(','))

###
  remove records from localstorage, dependent to intervals names
###
clearAllIntervals = ->
  names = window.localStorage.getItem(intervalNames)
  return unless names
  names.split(',').forEach (name) ->
    clear(name)

`export default Intervals`
