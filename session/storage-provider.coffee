`import Provider from '../../utils/session/provider'`
`import Ember from 'ember'`

StorageProvider = Provider.extend

  name: 'storage'

  getProviderData: (method, userData) ->
    result = Ember.$.Deferred()
    token = userData?.access_token or window.localStorage.getItem('token')
    userId = userData?.user_id or window.localStorage.getItem('userId')
    if token and userId
      result.resolve(api_key:{access_token: token, user_id: userId})
    else
      result.reject()
    return result.promise()

`export default StorageProvider`
