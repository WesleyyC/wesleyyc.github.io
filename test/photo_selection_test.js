'use strict';

const assert = require('node:assert/strict');
const { selectRandom } = require('../js/photo-selection.js');

const pool = Array.from({ length: 24 }, (_, index) => `photo-${index + 1}`);

const lowSelection = selectRandom(pool, 12, () => 0);
const highSelection = selectRandom(pool, 12, () => 0.999999);

assert.equal(lowSelection.length, 12, 'a page view should display exactly 12 photographs');
assert.equal(new Set(lowSelection).size, 12, 'the displayed photographs should be unique');
assert.notDeepEqual(lowSelection, highSelection, 'different random streams should produce different subsets');
assert.deepEqual(pool, Array.from({ length: 24 }, (_, index) => `photo-${index + 1}`), 'selection must not mutate the curated pool');
assert.deepEqual(selectRandom(pool, 30, () => 0.5).sort(), pool.slice().sort(), 'requesting more than the pool should return each photograph once');

console.log('photo selection: 5 assertions passed');
