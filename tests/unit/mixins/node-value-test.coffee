`import Ember from 'ember'`
`import NodeValueMixin from '../../../mixins/node-value'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | node value'

# Replace this with your real tests.
test 'it works', (assert) ->
  NodeValueObject = Ember.Object.extend NodeValueMixin
  subject = NodeValueObject.create()
  assert.ok subject
