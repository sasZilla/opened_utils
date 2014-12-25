`import Provider from 'ccquest/utils/session/provider'`
`import Ember from 'ember'`

ProfileProvider = Provider.extend

  name: 'profile'

  getProviderData: (method, userData)->
    if method == 'update'
      if userData.password and userData.full_name
        parts = userData.full_name.trim().split(/\s+/)
        userData.first_name = parts?.shift()
        userData.last_name  = parts?.join(' ')
        userData.password_confirmation = userData.password_confirmation
      else
        result = Ember.$.Deferred()
        result.reject('Please fill out form coorectly')
        return result.promise()
    return @_super(method, userData)


`export default ProfileProvider`
