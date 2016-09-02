`import Ember from 'ember'`
`import TagNameGetterMixin from '../../../mixins/tag-name-getter'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | tag name getter'

# Replace this with your real tests.
test 'it works', (assert) ->
  TagNameGetterObject = Ember.Object.extend TagNameGetterMixin
  subject = TagNameGetterObject.create()
  assert.ok subject
