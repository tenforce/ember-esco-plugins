`import Ember from 'ember'`

sortByPromise= (list, path) ->
  unless Ember.isArray(path)
    path = [path]

  promises = list.map (item) ->
    hash = {}
    path.map (key) ->
      hash[key] = new Ember.RSVP.Promise (resolve) -> resolve(Ember.get(item, key))
    Ember.RSVP.hash hash
  Ember.RSVP.all(promises).then (resolutions) ->
    toSort = resolutions.map (solutions, index) ->
      result = { _sorterItem: list.objectAt(index) }
      for key, solution of solutions
        result[key] = solution
      result
    sorted = toSort.sortBy.apply toSort, path
    sorted.map (item) ->
      item._sorterItem

`export default sortByPromise`
