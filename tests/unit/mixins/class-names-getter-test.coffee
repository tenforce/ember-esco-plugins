`import Ember from 'ember'`
`import ClassNamesGetterMixin from '../../../mixins/class-names-getter'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | class names getter'

# Replace this with your real tests.
test 'it works', (assert) ->
  ClassNamesGetterObject = Ember.Object.extend ClassNamesGetterMixin
  subject = ClassNamesGetterObject.create()
  assert.ok subject
