`import Ember from 'ember'`
`import sortByPromise from '../utils/sort-by-promise'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import layout from '../templates/components/taxonomy-browser'`

###
# component to browse and search taxonomies as defined in ESCO
###
TaxonomyBrowserComponent = Ember.Component.extend KeyboardShortcuts,
  layout:layout
  classNames: ["hierarchy"]
  keyboardShortcuts:
    'up':
      action: 'up'
      global: false
    'down':
      action: 'down'
      global: false
    'ctrl+alt+d':
      action: 'deleteSearchString'
      scoped: true

  store: Ember.inject.service('store')
  hierarchyService: Ember.inject.service()

  # page size for hierarchy
  pageSize: 50

  # Language to show the tree in
  language: "en"

  # the target concept being focused on in the hierarchy
  target: Ember.computed.alias 'hierarchyService.target'

  init: ->
    @_super(arguments...)

  # Title text for filter on mouse over
  filterTitle: Ember.computed 'showFilter', ->
    if @get('showFilter') then return "hide options"
    else return "more options"

  activateNode: (node) ->
    @sendAction 'activateItem', node

  # Format of filters
  # [
  #   {
  #     name: "All",
  #     id: null
  #   },
  #   {
  #     name: "To be translated",
  #     id: "70d7bd9f-107a-40dd-91f7-9bd210b7e7fc",
  #     params: {
  #       language: "en",
  #       status: "toDo"
  #     }
  #   },
  #   {
  #     name: "In progress",
  #     id: "70d7bd9f-107a-40dd-91f7-9bd210b7e7fc",
  #     params: {
  #       language: "en", 
  #       status: "inProgress" 
  #     }
  #   }
  # ]
  filterTypes: [] 

  loading: Ember.computed.not 'displayTypes'
  # the possible ways to display the taxonomy
  displayTypesObserver: Ember.observer 'taxonomy', ( ->
    @fetchHierarchies(@get('taxonomy')).then (displayTypes) =>
      @set 'displayTypes', displayTypes
  ).on('init')

  # change the display type back to default when the taxonomy changes
  taxonomyObserver: Ember.observer 'taxonomy', 'defaultDisplayType', (->
    @set 'displayType', @get 'defaultDisplayType'
  ).on('init')

  # TODO pass in default (one way)
  # whether or not to show the full detail of the filter
  showFilter: false

  # whether or not we are searching right now
  searchActive: false

  # ensures the list view is shown when searching
  ensureListWhenSearching: Ember.observer 'searchActive', 'displayTypes', ->
    Ember.run.later =>
     if @get 'searchActive'
       listType = null
       @get('displayTypes')?.map (display) ->
         if display.type == "list"
           listType = display
       if listType
         @set 'displayType', listType
 
  # fetching the children of the current node
  fetchChildren: (display, target, filter) ->
    filter = @get('filterType')
    @get('hierarchyService').getChildren(display,target, filter).then (result) =>
      idslists = []
      sortkey = @get 'sortKey'
      result.data.map (node, index) =>
        listIndex = Math.floor(index / 40)
        idslists[listIndex] ||= []
        idslists[listIndex].push node.id
      promises = idslists.map (list) =>
        @get('store').query 'concept',
          filter: {id: list.join(',')}
          include: "pref-labels.pref-label-of"
      Ember.RSVP.all(promises).then (lists) ->
        result = []
        lists.map (list) ->
          list.map (item) ->
            result.push item
        sortByPromise(Ember.ArrayProxy.create(content: result), sortkey)

  # the top concepts of the taxonomy
  topConcepts: Ember.computed 'taxonomy', 'taxonomy.children', 'sortKey', 'defaultExpanded', ->
    @get('taxonomy.children')?.then (children) =>
      children.forEach (child) ->
        child.set('anyChildren', true)
      sortByPromise(children,@get('sortKey'))

  # how to sort the top concepts
  sortKey: ["defaultCode", "preflabel"]
  
  # the default display type to use
  defaultDisplayType: Ember.computed 'displayTypes', ->
    displays = @get 'displayTypes'
    selected = null
    displays?.map (item) ->
      if Ember.get item, 'default'
        selected = item
    selected

  # when the display type changes, make sure the search stops in hierarchy mode
  displayTypeObserver: Ember.observer 'displayType', ->
    if @get('displayType.type') == "hierarchy"
      @set 'searchActive', false
    else
      @set 'filterType', @filterTypes[0]
      @set 'searchActive', true
      @performSearch(@get 'searchQuery')

  # when filtering make sure the top concepts are computed again so the tree is rerendered
  filterTypeObserver: Ember.observer 'filterType', ->
    @get 'filterType'
    @notifyPropertyChange 'topConcepts'

  config: Ember.computed 'baseConfig', 'defaultExpanded', ->
    filter = @get 'filterType'
    display = @get 'displayType'
    base = @get 'baseConfig' or {}
    Ember.Object.create base,
      expandedConcepts: @get('defaultExpanded') or []
      getChildren: (model) =>
        @fetchChildren(display.id, model.get('id'), filter).then (children) =>
          if children.length > 0
            model.set('anyChildren', true)
          else
            model.set('anyChildren', false)
          children 

  # validate the search string, has to have at least 2 characters
  goodSearchString: Ember.computed 'searchQuery', ->
    @get('searchQuery')?.length > 2

  # if the selected filter changes, also make sure the filterType object is changed
  filterObserver: Ember.observer 'filterTypes', (->
    filter = @get 'filter'
    target = null
    if filter
      target = @get('filterTypes').filterBy('filter', filter)[0]
    @set 'filterType', target or @get('filterTypes')[0]
  ).on('init')
  
  # which concepts are to be expanded automatically
  expanded: Ember.computed 'target','displayType', ->
    target = @get 'target'
    display = @get 'displayType'
    filter = @get 'filterType'
    if target and display
      @get('hierarchyService').getAncestors(display.id, target, (not filter.filter)).then (expanded) =>
        expanded = expanded.data.map (item) -> item.id
    else if display
      new Ember.RSVP.Promise (resolve) -> resolve([])
    else
      null
  
  expandedObserver: Ember.observer 'expanded', ( ->
    if not @get('defaultExpanded')
      @get('expanded')?.then (result) =>
        @set 'defaultExpanded', result
  ).on('init')

  # perform an actual search
  performSearch: (query) ->
    @set 'searchQuery', query
    @set 'maxPage', 0
    @set 'searchActive', true
    store = @get('store')
    if @get 'goodSearchString'
      @set 'searchLoading', true

      @_getSearchResults(query).then (data) =>
          # uuid of the conceptscheme
          searchOrigin = @get('taxonomy.id')
          filtered = data.filter (element) =>
            element?.attributes?.type?.indexOf(searchOrigin) >= 0

          filtered.sort (a,b) ->
            if(a?.attributes?.score > b?.attributes?.score)
              return -1
            else
             if(b?.attributes?.score > a?.attributes?.score)
               return 1
             else
               return 0

          ids = filtered.map (item) ->
            item.id

          store.query('concept',
            filter: {id: ids.join(',')}
            include: "pref-labels"
          ).then (items) =>
            idMap = {}
            items.map (item) ->
              idMap[item.get('id')] = item
            orderedItems = []
            ids.map (id) ->
              if idMap[id]
                orderedItems.push idMap[id]
            @set 'searchResults', orderedItems
            @set 'searchLoading', false

        error: ->
          @set 'searchResults', Ember.A()
          @set 'searchLoading', false

  # fetch the search results based on the language and the taxonomy
  # always also search in english
  _getSearchResults: (query) ->
    promises = []
    promises.push Ember.$.ajax
        url: '/indexer/search/similar',
        type: 'GET',
        data: {
          'conceptScheme': @get('taxonomy.id'),
          'locale': @get('language'),
          'text': query,
          'numberOfResults': @get('pageSize')
        },
        contentType: "application/json",
        
    promises.push Ember.$.ajax
        url: '/indexer/search/similar',
        type: 'GET',
        data: {
          'conceptScheme': @get('taxonomy.id'),
          'locale': "en",
          'text': query,
          'numberOfResults': @get('pageSize')
        },
        contentType: "application/json",

    Ember.RSVP.all(promises).then((results) =>
      searched = []
      results.map (result) ->
        result.data.map (item) ->
          searched.push item

      seen = {}
      filtered = []
      searched.map (item) ->
        unless seen[item.id]
          seen[item.id] = true
          filtered.push item
      filtered
    ).catch =>
      []
  # maximum index to search in search results
  maxIndex: Ember.computed 'pageSize', 'maxPage', ->
    @get('pageSize')*(@get('maxPage')+1)
  # sliced version of search results
  pagedResults: Ember.computed 'searchResults', 'maxIndex', ->
    @get('searchResults').slice(0, @get('maxIndex') )
  # are there more pages in the search results?
  canLoadMore: Ember.computed 'searchResults', 'maxIndex', ->
    @get('searchResults').length > @get('maxIndex')-2

  # fetches the hierarchies for a given taxonomy and adds the default hierarchies too
  fetchHierarchies: (taxonomy) ->
    taxonomy.get('structures').then (structures) =>
      hierarchyDescriptions = structures.map (item,index) ->
        name: item.get('name')
        type: "hierarchy"
        id: item.get('id')
      hierarchyDescriptions.push
        name: "List"
        type: "list"
        id: "list"
      hierarchyDescriptions.push
        name: taxonomy.get('preflabel')
        type: "hierarchy"
        default: true
        id: taxonomy.get('id')
      hierarchyDescriptions

  actions:
    up: ->
      unless $('.selected').length > 0
        @get('topConcepts').then (topconcepts) =>
          child = topconcepts[topconcepts.length-1]
          if child?.get('hasChildren') then @sendAction 'activateItem', child
    down: ->
      unless $('.selected').length > 0
        @get('topConcepts').then (topconcepts) =>
          child = topconcepts[0]
          if child?.get('hasChildren') then @sendAction 'activateItem', child
    search: (query) ->
      @performSearch query
    activateItem: (item) ->
      @sendAction 'activateItem', item
    toggleFilter: ->
      @set 'showFilter', not @get 'showFilter'
      false
    returnToHierarchy: ->
      @set 'displayType', @get 'defaultDisplayType'
    loadMore: ->
      @incrementProperty 'maxPage'
      false
    selectOlderBrother: (index) ->
      @get('topConcepts').then (topconcepts) =>
        child = topconcepts[index-1]
        if child?.get('hasChildren') then @sendAction 'activateItem', child
    selectYoungerBrother: (index) ->
      @get('topConcepts').then (topconcepts) =>
        child = topconcepts[index+1]
        if child?.get('hasChildren') then @sendAction 'activateItem', child
    deleteSearchString: ->
      @set('searchString', '')

`export default TaxonomyBrowserComponent`