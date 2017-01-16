`import Ember from 'ember'`
`import layout from '../templates/components/search-result'`

SearchResultComponent = Ember.Component.extend(
  layout:layout
  tagName: 'div'
  classNames: ['aet-node']
  attributeBindings: ['tooltipNode:title']

  setLabel: Ember.observer('labelPropertyPath', 'model', () ->
    key = "model.#{@get('labelPropertyPath')}"
    Ember.defineProperty @, "label",
      Ember.computed 'labelPropertyPath', 'model', key, ->
        @get("model.#{@get('labelPropertyPath')}")
  ).on('init')

  actions:
    activateItem: (item) ->
      @sendAction('activateItem', item)
)

`export default SearchResultComponent`
