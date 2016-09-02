`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'taxonomy-browser', 'Integration | Component | taxonomy browser', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{taxonomy-browser}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#taxonomy-browser}}
      template block text
    {{/taxonomy-browser}}
  """

  assert.equal @$().text().trim(), 'template block text'
