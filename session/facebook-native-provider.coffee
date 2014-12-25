#Android Native application use content: as protocl for file access
#iOS Native application use file: protocol
#In native applications we use android or ios Facebook SDK wrapped by Rho extension

`import Provider from 'ccquest/utils/session/provider'`
`import Ember from 'ember'`

FacebookNativeProvider = Provider.extend
  fbLoginComplete: null

  init: ->
    Rho?.Application.setApplicationNotify (params) ->
      if params
        Rho.Log.info(params.applicationEvent, "FB_PARAMS")
      else
        Rho.Log.info("empty", "FB_PARAMS")

      Rho.Facebooklogin.onAppActivate(params)

    #ios : workaround - call activate first time
    if document.location.protocol is 'file:'
      data =
        'applicationEvent' : 'Activated'
      Rho.Facebooklogin.onAppActivate(data)

  getProviderData: ()->
    fbLoginPromise = null
    reject = null

    fbLoginPromise = new Ember.RSVP.Promise (resolve, reject) =>
      @fbLoginComplete = resolve
      reject = reject

    Rho?.Facebooklogin.doLoginWithUI (response) =>
      if response.status is "connected"
        @processFBResponse(response)
      else
        @signOut()
        reject("Facebook login failed.")

    return fbLoginPromise

  getFBUSerAgent: () ->
    switch
      when /iPhone|iPod|iPad/.test(navigator.userAgent) then "ios"
      when /Android/.test(navigator.userAgent) then "android"
      else
        null

# create the user in the API
  processFBResponse: (response) ->
    user = response.account
    data =
      first_name: user.first_name
      last_name: user.last_name
      email: user.email
      username: user.username
      fb_user_id: user.id
      provider: 'facebook'
      role: 'student'
      userAgent: @getFBUSerAgent()
      accessToken: response.authResponse.accessToken

    @fbLoginComplete(data)

  signOut: ->
    # try to log out from fb and return promise
    Rho?.Facebooklogin.doLogout()
    result = Ember.$.Deferred()
    result.resolve()
    return result.promise()

`export default FacebookNativeProvider`
