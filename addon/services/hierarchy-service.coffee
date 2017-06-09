`import Ember from 'ember'`

HierarchyService = Ember.Service.extend
  cache: {}
  ancestorCache: {}
  _fetchCached: (call) ->
    @get('cache')[call]
  _cacheCall: (call, promise) ->
    cache = @get 'cache'
    cache[call] = promise
  _clearCache: ->
    @set('cache', {})
  _performCall: (call, uncache) ->
    promise = @_fetchCached(call)
    if uncache or not promise
      promise = new Ember.RSVP.Promise (resolve, reject) =>
        internalCall = (count) ->
          Ember.$.ajax call,
            headers:
              'Accept': 'application/json'
            success: resolve
            error: =>
              if count < 5
                console.log "Call to HierarchyService for #{call} failed, retrying"
                internalCall(count + 1)
              else reject


        internalCall 0

    @_cacheCall(call, promise)
    promise

  getAncestors: (display, target, uncache) ->
    call = "/hierarchy/#{display}/#{target}/ancestors"
    @_performCall(call,uncache)

  getChildren: (display, target, filter, uncache) ->
    subcall = ""
    if filter and filter.id
      subcall = "?filter=#{filter.id}"
      for key, value of (filter.params or {})
        subcall += "&filter-"+key+"="+value

    call = "/hierarchy/#{display}/#{target}/descendants"+subcall
    @_performCall(call,uncache)

  getTopConcepts: (display, uncache) ->
    call = "/structure/#{display}/top-concepts"
    @_performCall(call,uncache)

`export default HierarchyService`
