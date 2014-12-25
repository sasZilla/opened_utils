### global FB ###
`import Provider from 'ccquest/utils/session/provider'`
`import Ember from 'ember'`
`import loadScript from 'ccquest/utils/load-scripts'`
`import config from 'ccquest/config/environment'`

FacebookProvider = Provider.extend

  _authPromise: null

  name: 'facebook'
  metricName: 'facebook'

  isEnabled: false

  isApiLoaded: false

  isBuggySafari: ( ->
    return navigator.userAgent.search('6.0.3 Safari') != -1
  ).property()

  getProviderData: (method, userData)->
    @set('userData', userData)
    result = Ember.$.Deferred()
    if @get('_authPromise')
      result.reject('Already in progress.')
    else
      @set('_authPromise', result)
      check = @checkFBEnabled()
      .then =>
        load = @initScript()
        .then =>
          @initFB()
        .fail ->
          @set('_authPromise', null)
          result.reject('Sorry! Cant access Facebook API')
      .fail ->
        @set('_authPromise', null)
        result.reject('Sorry! Cant access Facebook host')
    return result.promise()

  checkFBEnabled: (->
    result = Ember.$.Deferred()
    if @get('isEnabled')
      result.resolve()
      return result.promise()
    if @get('isBuggySafari')
      result.reject()
    else
      img = new Image()
      img.onload = =>
        result.resolve()
        @set('isEnabled', true)
      img.onerror = ->
        result.reject()
      img.src = "https://facebook.com/favicon.ico"
    return result.promise()
  ).on('init')

  #load FB script
  initScript: ->
    result = Ember.$.Deferred()
    if @get('isApiLoaded')
      result.resolve()
    else
      loadScript '//connect.facebook.net/en_US/sdk.js', 'facebook-jssdk', =>
        @set('isApiLoaded', true)
        result.resolve()
      , ->
        result.reject()
    return result.promise()

  #Init Facebook Api
  initFB: ->
    result = Ember.$.Deferred()
    unless @get('isApiInited')
      FB.init
        appId      : config.FB_APP_ID,
        status     : false, # don't check login status on load
        cookie     : false, # we dont need facebook cookies we have our own storage session
        xfbml      : false  # parse XFBML
        version    : config.FB_API_VERSION

    @set('isApiInited', true)
    FB.getLoginStatus (response) =>
      if response.status == 'connected'
        @initGraphInfo(response)
      else
        FB.login (response)=>
          if(response.authResponse)
            @initGraphInfo(response)
          else
            resp = @get('_authPromise')
            @set('_authPromise', null)
            resp.reject('Can not signin with Facebook. Please try again')
        , {scope: 'email'}
    return result

  #get init user data
  initGraphInfo: (response) -> #TODO make user data more freindly... and add to intergrate it with session util
    if response.authResponse
      FB.api '/me', (me) =>
        key = @set "apiKey", Ember.Object.create
          accessToken: response.authResponse.accessToken
          user:
            first_name: me.first_name
            last_name: me.last_name
            username: me.username
            email: me.email
            role: @get('userData')?.role
            fb_user_id: me.id
            provider: 'facebook'
            promo: me.promo
            code: @get('userData')?.code
            signedRequest: response.authResponse.signedRequest
        if promise = @get('_authPromise')
          @set('_authPromise', null)
          promise.resolve(key.apiKey.user)

  signOut: ->
    result = Ember.$.Deferred()
    FB.getLoginStatus (resp) ->
      if resp.authResponse
        FB.api '/me/permissions', 'delete', ->
          result.resolve()
      else
        result.resolve()
    return result.promise()

`export default FacebookProvider`
