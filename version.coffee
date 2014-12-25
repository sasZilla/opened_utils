`import Ember from 'ember'`
`import config from '../config/environment'`

Version = Ember.Object.extend
  _poll: (callback, interval) ->
    Ember.run.later =>
      callback().then =>
        @_poll(callback, interval)
      , =>
        @_poll(callback, interval)
    , interval

  _checkVersion: ->
    Ember.$.ajax
      type: 'GET'
      url: config.VERSION.url
    .then (result) =>
      if @get('version') is undefined
        @set 'version', result
      else
        if result isnt @get('version')
          window.location.reload true

  init: ->
    if interval = config.VERSION.interval
      @_poll =>
        @_checkVersion()
      , interval

`export default Version`
