/* jshint node: true */
'use strict';

module.exports = {
  name: 'ember-esco-plugins',
  included: function(app) {
    this._super.included.apply(this, arguments);
    if (typeof app.import !== 'function' && app.app) {
      app = app.app;
    }
  },
  isDevelopingAddon: function() {
    return true;
  }
};
