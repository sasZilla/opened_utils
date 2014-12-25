`import Ember from 'ember'`

Provider = Ember.Object.extend

  name: false
  metricName: 'OpenEd'

  getProviderData: (method, userData)->
    result = Ember.$.Deferred()
    result.resolve(userData)
    return result.promise()

  signOut: ->
    result = Ember.$.Deferred()
    result.resolve()
    return result.promise()


`export default Provider`
