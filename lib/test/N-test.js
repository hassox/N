(function(){
  var N, assert, nSuite, vows;
  N = require('../index');
  vows = require('vows');
  assert = require('assert');
  nSuite = vows.describe('N Object');
  nSuite.addBatch({
    'Stack': {
      'prime stack': {
        topic: N.primeStack,
        'should be array': function(topic) {
          return assert.isArray(topic);
        }
      },
      'stack instance': {
        topic: N.stackInstance,
        'should be an object': function(topic) {
          return assert.isObject(topic);
        }
      }
    }
  });
  module.exports.nSuite = nSuite;
})();
