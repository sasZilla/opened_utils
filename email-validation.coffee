`import request from 'ic-ajax'`
`import Ember from 'ember'`
`import config from 'ccquest/config/environment'`

regExp = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

emailValidation = (email) ->
  result = Ember.$.Deferred()
  error = false
  unless validateRegExp(email)
    result.reject()
    error = true
  unless error
    validateRemote(email)
    .then (resp) -> #success
      if resp.is_valid
        result.resolve()
      else
        result.reject(resp)
    , -> #error
      result.resolve()
  return result.promise()

validateRegExp = (email) ->
  return regExp.test(email)

validateRemote = (email) ->
  return request
    type: 'GET'
    url: config.EMAIL_VALIDATION_HOST
    data: { address: email, api_key: config.MAILGUN_API_KEY }
    dataType: 'jsonp'
    crossDomain: true


`export default emailValidation`
