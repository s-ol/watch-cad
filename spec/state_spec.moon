import Once, State from require 'state'

describe "Once", ->
  it "stores a value", ->
    a = Once 3
    assert.is.equal 3, a.value

  it "can test for itself", ->
    assert.is_true Once.is_once Once 3
    assert.is_true Once.is_once Once 2
    assert.is_true Once.is_once Once nil
    assert.is_true Once.is_once Once { a: 3 }

  it "can test other types", ->
    assert.is_falsy Once.is_once nil
    assert.is_falsy Once.is_once 3
    assert.is_falsy Once.is_once "once impostor"
    assert.is_falsy Once.is_once { a: 3 }

describe "State", ->
  local S
  before_each ->
    state = State!
    S = state.state

  it "can be indexed infinitely", ->
    assert.is_table S.a.b.c.d

  describe ":init", ->
    it "stores default until changed", ->
      S\init 'test', 2
      assert.is.equal 2, S.test

      S.test = 4
      assert.is.equal 4, S.test

      S\init 'test', 2
      assert.is.equal 4, S.test

  describe ":store", ->
    it "stores defaults until changed", ->
      S\store 'test', nil, 3
      assert.is.equal 3, S.test

      S\store 'test', nil, 4
      assert.is.equal 3, S.test

    it "follows live inputs", ->
      S\store 'test', 3, 'nope'
      assert.is.equal 3, S.test

      S\store 'test', 4, 'nope'
      assert.is.equal 4, S.test

    it "lets Once() inputs override defaults", ->
      S\store 'test', (Once 3), 'nope'
      assert.is.equal 3, S.test

      S\store 'test', 'changed'

      S\store 'test', (Once 4), 'nope'
      assert.is.equal 'changed', S.test
