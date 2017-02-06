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
        Ember.$.ajax call,
          headers:
            'Accept': 'application/json'
          success: resolve
          error: reject
    @_cacheCall(call, promise)
    promise

  getAncestors: (display, target, uncache) ->
    call = "/hierarchy/#{display}/ancestors/#{target}"
    @_performCall(call,uncache)
    
  getChildren: (display, target, filter, uncache) ->
    subcall = ""
    if filter and filter.id
      subcall = "?filter=#{filter.id}"
      for key, value of (filter.params or {})
        subcall += "&filter-"+key+"="+value
    
    call = "/hierarchy/#{display}/target/#{target}"+subcall 
    @_performCall(call,uncache)

`export default HierarchyService`
