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
  local state
  before_each ->
    state = State!

  it "stores values", ->
    assert.is_nil state.values['my key']
    state.values['my key'] = 'my val'
    assert.is_equal 'my val', state.values['my key']

    state.values['more'] = 4
    assert.is_equal 4, state.values['more']
    assert.is_equal 'my val', state.values['my key']

  it "can be reset", ->
    state.values['my key'] = 'my val'
    state.values['more'] = 4

    state\reset!
    assert.is_nil state.values['my key']
    assert.is_nil state.values['more']

  describe "cursors", ->
    it "can be nested with :get_nested()", ->
      assert.is_table state.root\get_nested 'a'
      assert.is_table state.root\get_nested('a')\get_nested 'b'

    it "delegate __index to :get_nested", ->
      assert.is_table state.root
      assert.is_table state.root.a
      assert.is_table state.root.a.b.c.d

    it "stringify to a key", ->
      assert.is_equal '', tostring state.root
      assert.is_equal 'a.b.c.d', tostring state.root.a.b.c.d

    it ":set() sets the value", ->
      cursor = state.root.test
      cursor\set 'the val'
      assert.is_equal 'the val', state.values[cursor]

    it ":set() returns the new value", ->
      assert.is_equal 'val', state.root.test\set 'val'

    it ":get() gets the value", ->
      cursor = state.root.test
      cursor\set 'the val'
      assert.is_equal 'the val', cursor\get!

    it ":init() sets the value unless already set", ->
      cursor = state.root.test
      cursor\init 'initial value'
      assert.is_equal 'initial value', cursor!

      cursor\init 'other value'
      assert.is_equal 'initial value', cursor!

    it ":init() returns the current value", ->
      cursor = state.root.test
      assert.is_equal 'initial value', cursor\init 'initial value'
      assert.is_equal 'initial value',  cursor\init 'other value'

    it "can be called to get the value", ->
      cursor = state.root.test
      assert.is_nil cursor!
      cursor\set 'the val'
      assert.is_equal 'the val', cursor!

    it "delegate __eq to string key", ->
      assert.is_true  state.root.a   == state.root.a
      assert.is_true  state.root.a.b == state.root.a.b
      assert.is_false state.root.a   == state.root.b
      assert.is_false state.root.a.b == state.root.a.c
      assert.is_false state.root.a.b == state.root.c.b

    describe ":drive()", ->
      it "follows live inputs", ->
        cursor = state.root.test
        cursor\drive 3
        assert.is_equal 3, cursor!

        cursor\drive 'test'
        assert.is_equal 'test', cursor!

      it "initializes with Once() inputs", ->
        cursor = state.root.test
        cursor\drive Once 'initial'
        assert.is_equal 'initial', cursor!

        cursor\drive Once 'other'
        assert.is_equal 'initial', cursor!

      it "returns the current value", ->
        cursor = state.root.test
        assert.is_equal 'initial', cursor\drive Once 'initial'
        assert.is_equal 'initial', cursor\drive Once 'other'
        assert.is_equal 'live in', cursor\drive 'live in'

