###

  Session handles all user authorization actions

  TODO transfer facebook signin/signup

###
`import request from 'ic-ajax'`
`import Ember from 'ember'`
`import config from '../../config/environment'`
`import ProvidersClassList from '../../utils/session/providers-list'`


Session = Ember.Object.extend Ember.Evented,

  currUser: null

  errorMessage: null

  isLoading: false

  afterLoadingQueue: []

  providers: ProvidersClassList

  ###
    method
    starts signin
    @param {String} provider - provider name
    @param {Object} accessData - user signin data
    @return {Promise}
  ###
  signIn: (provider, accessData)->
    @set('errorMessage', null)
    @set('isLoading', true)
    access = @sessionAccess('signin', provider, accessData)
    return @_responseFlow(access, 'signin', accessData)

  ###
    method
    starts signup
    @param {String} provider - provider name
    @param {Object} accessData - user signup data
    @return {Promise}
  ###
  signUp: (provider, accessData)->
    result = Ember.$.Deferred()
    @set('errorMessage', null)
    @set('isLoading', true)
    access = @sessionAccess('signup', provider, accessData)
    return @_responseFlow(access, 'signup', accessData)

  ###
    method
    starts signout
    @param {String} url - will be redirected to this url after signOut
    @return {Promise}
  ###
  signOut: (url = '/')->
    result = Ember.$.Deferred()
    currProvider = @get('currProvider')
    @set('errorMessage', null)
    @set('isLoading', true)
    if @get('currUser')
      if currProvider
        @getProvider(currProvider).signOut()
        .then =>
          @triggerSignOffFlow()
        .always =>
          @set('currProvider', null)
          @set('isLoading', false)
          @set('currUser', null)
          Ember.run.next ->
            window.location = url
            result.resolve()
      @_removeLocalStorageInfo()
    else
      result.resolve()
    #TODO add reset App thing
    return result.promise()

  ###

    Triggers auth redirect flow event on success

  ###
  triggerAuthFlow: (method, response, accessData)->
    @trigger('auth', method, response, accessData)
    @trigger('auth.metrics', method, response, accessData)

  ###

    Triggers error flow

  ###
  triggerErrorFlow: (method, error, accessData)->
    @trigger('autherror', method, error, accessData)
    @trigger('autherror.metrics', method, error, accessData)

  triggerSignOffFlow: ->
    @trigger('unauth')

  ###

    Queue callback system. Fires callbacks when session is ready for it
    Use only this method to access other Session methods

  ###
  afterLoading: (callback)->
    if @get('isLoading')
      @get('afterLoadingQueue').push(callback)
    else
      callback()

  _afterLoadingWorker: (->
    unless @get('isLoading')
      while @get('afterLoadingQueue').length and !@get('isLoading')
        callback = @get('afterLoadingQueue').shift()[0]
        callback() if callback
  ).observes('isLoading')

  ###

    Gets Provider acees data and invokes session request

  ###
  sessionAccess: (method, provider, accessData)->
    @set('isLoading', true)
    result = Ember.$.Deferred()
    @getProvider(provider).getProviderData(method, accessData)
    .then (providerData)=>
      if method == 'auth'
        auth = @_authenticate(providerData)
        auth.then (response)=>
          @set('currProvider', provider)
          @triggerAuthFlow(method, response, accessData)
          result.resolve.apply(result, arguments)
          @set('isLoading', false)
        auth.catch (error)=>
          @triggerErrorFlow(method, error, accessData)
          result.reject('auth failed')
          @set('isLoading', false)
      else
        req = @_sessionAccess(method, providerData)
        req.then (response)=>
          auth = @_authenticate(response, true)
          auth.then =>
            @set('currProvider', provider)
            result.resolve(response)
            @set('isLoading', false)
          auth.fail (error)=>
            result.reject(error)
            @set('isLoading', false)
        req.catch (error)=>
          result.reject(error)
          @set('isLoading', false)
    .fail =>
      result.reject.apply(result, arguments)
      @set('isLoading', false)
    return result.promise()

  getProvider: (providerName)->
    return @get('providers.' + providerName)

  getCurrProvider: ()->
    return @getProvider( @get('currProvider') )

  ###

    Session request

  ###
  _sessionAccess: (method, accessData) ->
    type = 'POST'
    type = 'PUT' if method == 'password' or method == 'update'
    req = request
      type: type
      url: config.API_HOST + config.API_URLS[method]
      data: accessData
      dataType: 'json'
    return req

  ###

    Inits current session and sets user

  ###
  _authenticate: (response, writeToStorage) ->
    userId = parseInt(response.api_key.user_id)
    token = response.api_key.access_token
    if writeToStorage then @_writeLocalStorageInfo(token, userId)
    @set('accessToken', token)
    Ember.$.ajaxSetup headers:
      Authorization: "Token token=#{token}"
    return @_setUser(userId)

  _setUser: (userId)->
    return @store.find('user', userId).then (user) =>
      return user if @get 'currUser'
      @set('currUser', user)
      return user

  _writeLocalStorageInfo: (token, userId) ->
    window.localStorage.setItem 'token', token
    window.localStorage.setItem 'userId', userId

  _removeLocalStorageInfo: ->
    window.localStorage.clear()

  ###

    Response flow

  ###
  _responseFlow: (response, method, accessData) ->
    response.always =>
      @set('isLoading', false)
    response.then (response)=>
      @triggerAuthFlow(method, response, accessData)
    response.fail (error)=>
      @set('errorMessage', error)
      @triggerErrorFlow(method, error, accessData)
    return response

`export default Session`
