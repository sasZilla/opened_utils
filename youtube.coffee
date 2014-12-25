###

  Youtube class init and load youtube video using youtubeApi

###

`import Ember from 'ember'`
`import loadScript from '../utils/load-scripts'`

# This regexp help to parse youtube url
regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/

Youtube = Ember.Object.extend
  w: window
  player: null
  url: null
  id: 'player'
  width: '100%'
  height: '400'

  # The API calls this function when the player's state changes.
  onStateChange: null

  init: ->
    # This code loads the IFrame Player API code asynchronously.
    loadScript('https://www.youtube.com/iframe_api', 'youTubeApiScript')

    if @w.YT and @w.YT.Player
      # Recreate player if already loaded the API
      Ember.run.next =>
        @set('player', @initApi())
    else
      # create new YouTube player from the API
      window.onYouTubeIframeAPIReady = =>
        @set('player', @initApi())

  # This function creates an <iframe> (and YouTube player)
  initApi: ->
    new @w.YT.Player('player', {
      height: @get('height')
      width: @get('width')
      videoId: @parse( @get('url') )
      events:
        onStateChange: @get('onStateChange')
    })

  destroy: ->
    delete(@w.onYouTubeIframeAPIReady)
    try
      # player may be not initialized
      @get('player')?.destroy()
    catch e

  parse: (url) ->
    match = url.match(regExp)
    if match&&match[7].length==11
      match[7]
    else
      url

`export default Youtube`
