getLocation = (href) ->
  l = document.createElement('a')
  l.href = href
  return l

`export default getLocation`
