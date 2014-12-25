###

  Async loading for external resources with a callback

###
loadScript = (path, id, callback, errorCallback) ->
  return false if id and document.getElementById id
  return false unless path
  el = document.createElement 'script'
  el.type = 'text/javascript'
  el.async = true
  el.src = path
  el.id = id if id
  el.onload = callback if callback
  el.onerror = errorCallback if errorCallback
  s = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore el, s
  return true

`export default loadScript`
