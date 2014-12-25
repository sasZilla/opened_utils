`import Provider from 'ccquest/utils/session/provider'`
`import Ember from 'ember'`
`import emailValidation from 'ccquest/utils/email-validation'`

FormProvider = Provider.extend

  name: 'form'

  getProviderData: (method, userData)->
    result = Ember.$.Deferred()
    requestData = {} #@getEventData(method, userData)
    @validate(userData)
    .then ->
      requestData.email = userData.email
      if method == 'signin' and userData.username
        requestData.email = userData.username
      requestData.password = userData.password
      if method == 'signup'
        requestData.role = userData.role
        requestData.promo = userData.promo
      result.resolve(requestData)
    .fail Ember.$.proxy(result.reject, result)
    return result.promise()

  validate: (userData)->
    result = Ember.$.Deferred()
    if userData.email
      emailValidation(userData.email)
      .then ->
        result.resolve()
      .fail ->
        result.reject('There is a problem with your email address: <i>' + userData.email + '</i>.</br></br>Please check the following:</br><ul><li>There may be a typo, if so please fix.</li><li>Your school may not allow emails from our company. If so, either use a different email or talk to your IT person.</li></ul>')
    else
      if userData.username
        result.resolve()
      else
        result.reject('No username or email provided')
    return result.promise()

  getEventData: (method, userData)->
    if method == 'signup'
      if userData.promo and userData.auto
        return {ref_evt: 'promo', code: userData.promo}
      if userData.role == 'student' and userData.classcode
        return {ref_evt: 'classcode'}
      return {ref_evt: 'direct_web'}
    else
      return {}


`export default FormProvider`
