`import Ember from 'ember'`
`import gaHelper from '../../utils/gahelper'`

SessionMetrics = Ember.Object.extend

  initMetricsEvents: (->
    @session.on('auth.metrics', @, @authMetricsFlow)
    @session.on('autherror.metrics', @, @errorMetricsFlow)
  ).on('init')

  resetMetricsEvents: ->
    @session.off('auth.metrics', @, @authMetricsFlow)
    @session.off('autherror.metrics', @, @errorMetricsFlow)

  authMetricsFlow: (method, response = {}, userData = {})->
    gaHelper.trackConversion(method)
    currUser = @session.get('currUser')
    @metrics.identify(@session)
    has_premium_access = !!currUser.get('hasPremiumAccess')
    data =
      role: currUser.get('role')
      has_premium_access: has_premium_access
      provider: @session.getCurrProvider().get('metricName')
      subscription: currUser.get('subscription')?.plan_name

    numArrived = if response.api_key and response.api_key.hasOwnProperty('num_arrived') then response.api_key.num_arrived else 0
    if method == 'signup' or (method == 'signin' and response.api_key and response.api_key.is_new_user) or numArrived > 0
      @metrics.fireTrackingPixels()
      @metrics.track 'SignUp', data
      if currUser.get('promo')
        @metrics.track 'SignUpAd', data
    else if method == 'signin'
      @metrics.track 'SignIn', data

    if numArrived > 0 and currUser.get('isStudent')
      @metrics.track 'StudentArrived'
      if currUser.get('managed')
        @metrics.track 'StudentArrivedUsername'
      else
        @metrics.track 'StudentArrivedEmail'

  errorMetricsFlow: (method, response = {}, userData = {})->
    if response and response.jqXHR
      try
        responseText = JSON.parse(response.jqXHR.responseText)
      catch
        errMsg = response.jqXHR.responseText
      status = response.jqXHR.status
    else
      status = 'error'
      responseText = response
    data =
      status: status
      errText: responseText
      email:  userData.email
      username: userData.username

    if method == 'signup'
      if userData.username
        @metrics.track('SignUpFailedUsername', data)
      else
        @metrics.track('SignUpFailedEmail', data)
    else
      @metrics.track('SignInFailed', data)


`export default SessionMetrics`
