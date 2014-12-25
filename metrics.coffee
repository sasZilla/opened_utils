###

  Metrics measure class - heap, intercom, googleAnalitic, AmazonPixel, FbPixel

###

`import Ember from 'ember'`
`import config from 'ccquest/config/environment'`
`import request from 'ic-ajax'`
`import Intervals from 'ccquest/utils/intervals'`

intervals = Intervals.create()

Metrics = Ember.Object.extend
  w: window

  eventsMap:
    intercom: Ember.A(['StudentSetGrade', 'HomePage','InviteFromMastery'])
    ga: Ember.A(['pageview'])
    server: Ember.A(['UserSession', 'MasteryViewed', 'ResourceConsumed', 'StudentInvitedUsername'])
    server_ui: Ember.A(['StudentInvitedUsername'])

  init: ->
    if config.USE_HEAP
      @initHeap(config.HEAP_APP_ID)

    if config.USE_INTERCOM
      # init and identify with undefined user
      @identifyIntercom({
        email: ''
        created_at: '1417457802'
        name: 'intercom default'
        role: 'student'
        user_id: '73650'
        app_id: config.INTERCOM_APP_ID
        user_hash: '1160795adf9cbcc3e50d37401d47ad9dadfbb4a59299eda8190a97df89dbe205'
        provider: 'OpenEd'
        promo: null
      })

    if config.USE_GA
      @initGA(config.GOOGLE_ANALYTICS_APP_ID)

  initHeap: (appId) ->
    @w.heap = @w.heap or []
    @w.heap.load = (t, e) =>
      window.heap.appid = t
      window.heap.config = e

      a = document.createElement("script")
      a.type = "text/javascript"
      a.async = not 0
      a.src = ((if "https:" is document.location.protocol then "https:" else "http:")) + "//cdn.heapanalytics.com/js/heap.js"

      n = document.getElementsByTagName("script")[0]
      n.parentNode.insertBefore a, n
      o = (t) ->
        ->
          window.heap.push [t].concat(Array::slice.call(arguments, 0))
          return

      p = [
        "identify"
        "track"
      ]
      c = 0

      while c < p.length
        @w.heap[p[c]] = o(p[c])
        c++
      return

    @w.heap.load(appId)

  initIntercom: (appId) ->
    # we need to add app_id when load intercom/widget/app_id
    @w.intercomSettings = @w.intercomSettings or {}
    @w.intercomSettings.app_id = @w.intercomSettings.app_id or appId;

    l = ->
      s = d.createElement("script")
      s.type = "text/javascript"
      s.async = true
      s.src = "https://static.intercomcdn.com/intercom.v1.js"
      x = d.getElementsByTagName("script")[0]
      x.parentNode.insertBefore s, x
      return
    d = document
    i = ->
      i.c arguments
      return

    i.q = []
    i.c = (args) ->
      i.q.push args
      return

    @w.Intercom = i
    l()

  initGA: (appId) ->
    ((i, s, o, g, r, a, m) ->
      i["GoogleAnalyticsObject"] = r
      i[r] = i[r] or ->
        (i[r].q = i[r].q or []).push arguments
        return

      i[r].l = 1 * new Date()

      a = s.createElement(o)
      m = s.getElementsByTagName(o)[0]

      a.async = 1
      a.src = g
      m.parentNode.insertBefore a, m
      return
    ) window, document, "script", "//www.google-analytics.com/analytics.js", "ga"

    @w.ga?('create', appId, 'auto')


  track: (name, metadata) ->
    if config.USE_HEAP
      @w.heap.track(name, metadata)

    if @w.Intercom and config.USE_INTERCOM and @eventsMap.intercom.contains(name)
      @w.Intercom('trackEvent', Ember.String.dasherize(name), metadata)

    if config.USE_GA and @eventsMap.ga.contains(name)
      @w.ga('send', name, metadata)

    if config.USE_SERVER_EVENTS and @eventsMap.server.contains(name)
      if @eventsMap.server_ui.contains(name)
        name += 'Ui'

      eventData =
        ref_evt: name
        source: config.SOURCE

      for attrname of metadata
        eventData[attrname] = metadata[attrname]

      request
        type: 'POST'
        url: config.API_HOST + config.API_URLS['events']
        data: eventData
        dataType: 'json'

  trackByInterval: (name, metadata) ->
    interval = intervals.get(name)
    return unless interval
    if interval.check()
      @track(name, metadata)
    interval.reset()

  identify: (session) ->
    @session = session
    @cu = session.get('currUser')

    if config.USE_HEAP
      @identifyHeap()

    if config.USE_INTERCOM
      @identifyIntercom()

    # create new UserSession interval if not exist
    # How a UserSession is defined:
    # Time-based expiry (including end of day):
    # - After 30 minutes of inactivity
    # - At midnight
    interval = intervals.new('UserSession', 1800)
    if interval.check() or !interval.load()
      interval.reset()
      @track('UserSession')

  identifyHeap: (currUser = @cu)->
    # use Custom API for Heap identify user
    useIdentity = true
    if /Android/.test(navigator.userAgent)
      androidVer = '4.4'
      if Rho?
        androidVer = Rho.System.osVersion

      arVer = androidVer.split(',')
      if arVer and arVer.length > 1
        useIdentity = arVer[0] >= 4 and arVer[1] >= 1

    if @w.heap? and useIdentity
      has_premium_access = if currUser.get('hasPremiumAccess') then true else false
      @w.heap.identify
        email: if currUser.get('email') then currUser.get('email') else currUser.get('username')
        role: currUser.get('role')
        has_premium_access: has_premium_access
        provider: @session.getCurrProvider().get('metricName')
        promo: config.PROMO or currUser.get('promo')
        subscription: currUser.get('subscription')?.plan_name
        opened_user_id: currUser.get('id')

  identifyIntercom: (settings, currUser = @cu) ->
    @w.intercomSettings = settings or
      email: currUser.get('email')
      created_at: currUser.get('timestamp')
      name: if (currUser.get('full_name') and currUser.get('full_name').length > 0) then currUser.get('full_name') else currUser.get('username')
      role: currUser.get('role')
      user_id: currUser.get('id')
      app_id: currUser.get('intercom_app_id')
      user_hash: currUser.get('intercom_user_hash')
      provider: @session.getCurrProvider().get('metricName')
      promo: config.PROMO or currUser.get('promo')

    ic = @w.Intercom
    if typeof ic is "function"
      ic "reattach_activator"
      ic "update", @w.intercomSettings
    else
      @initIntercom(config.INTERCOM_APP_ID)

  fireTrackingPixels: ->
    if config.USE_FIRE_FB_PIXEL
      @fireFbPixel()
    if config.USE_FIRE_AMAZON_PIXEL
      @fireAmazonPixel()

  fireAmazonPixel: ->
    _pix = document.getElementById("_pix_id")
    unless _pix
      protocol = ((if ("https:" is document.location.protocol) then "https://" else "http://"))
      a = Math.random() * 1000000000000000000
      _pix = document.createElement("img")
      _pix.setAttribute "src", protocol + "s.amazon-adsystem.com/iu3?d=forester-did&ex-fargs=%3Fid%3D4fa73efc-40a4-4f30-91f7-599582543e9c%26type%3D6%26m%3D1&ex-fch=416613" + "&cb=" + a
      _pix.setAttribute "id", "_pix_id"
      _pix.style.display = 'none'
      document.body.appendChild _pix

  fireFbPixel: ->
    (->
      _fbq = window._fbq or (window._fbq = [])
      unless _fbq.loaded
        fbds = document.createElement("script")
        fbds.async = true
        fbds.src = "//connect.facebook.net/en_US/fbds.js"
        s = document.getElementsByTagName("script")[0]
        s.parentNode.insertBefore fbds, s
        _fbq.loaded = true
      return
    )()
    window._fbq = window._fbq or []
    window._fbq.push ["track","6020739636937",{ value: "0.00", currency: "USD" }]

`export default Metrics`
