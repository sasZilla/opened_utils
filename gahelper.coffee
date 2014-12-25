###

  Google analitycs conversion helper

###

`import Ember from 'ember'`
`import loadScript from '../utils/load-scripts'`
`import config from '../config/environment'`

gaHelper = Ember.Object.create
  conversions:
    signup:
      id: config.GOOGLE_CONVERSION_ID
      label: 'DiYxCK_b0gUQgcOO2AM'

    signin:
      id: config.GOOGLE_CONVERSION_ID
      label: 'DiYxCK_b0gUQgcOO2AM'

  trackRemarketing: () ->
    return unless config.USE_GC
    loadScript '//www.googleadservices.com/pagead/conversion_async.js', null, ->
      image = new Image(1,1)
      image.style = "border-style:none;"
      image.src = "//googleads.g.doubleclick.net/pagead/viewthroughconversion/#{config.GOOGLE_CONVERSION_ID}/?value=0&guid=ON&script=0"

  trackConversion: (name) ->
    return unless config.USE_GC
    conv = @conversions[name]
    if conv
      image = new Image(1,1)
      image.src = '//www.googleadservices.com/pagead/conversion/' +
      "#{conv.id}/?label=#{conv.label}&value=1&guid=ON&script=0"

`export default gaHelper`
