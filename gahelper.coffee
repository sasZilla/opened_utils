###

  Google analitycs conversion helper

###

`import Ember from 'ember'`
`import loadScript from 'ccquest/utils/load-scripts'`
`import config from 'ccquest/config/environment'`

gaHelper = Ember.Object.create
  conversions: {}
  trackRemarketing: () ->

    loadScript '//www.googleadservices.com/pagead/conversion_async.js', null, ->
      image = new Image(1,1)
      image.style = "border-style:none;"
      image.src = "//googleads.g.doubleclick.net/pagead/viewthroughconversion/#{config.GOOGLE_CONVERSION_ID}/?value=0&guid=ON&script=0"

  trackConversion: (name) ->
    conv = @conversions[name]
    if conv
      image = new Image(1,1)
      image.src = '//www.googleadservices.com/pagead/conversion/' +
      "#{conv.id}/?label=#{conv.label}&value=1&guid=ON&script=0"

`export default gaHelper`
