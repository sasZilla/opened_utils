`import Provider from 'ccquest/utils/session/provider'`
`import Ember from 'ember'`

TokenProvider = Provider.extend

  name: 'token'

  getProviderData: (method, userData)->
    result = Ember.$.Deferred()
    token = userData.access_token
    if token
      result.resolve(access_token: token)
    else
      result.reject('no token')
    return result.promise()

`export default TokenProvider`
