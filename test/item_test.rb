require 'test_helper'

describe Linked::Item do
  subject { ::Linked::Item }

  let(:item) { subject.new }
  let(:item_in_list) { subject.new(list: list) }
  let(:item_a) { subject.new }
  let(:item_b) { subject.new }
  let(:item_c) { subject.new }

  let(:sibling) { subject.new }

  let(:head) { Minitest::Mock.new }
  let(:tail) { Minitest::Mock.new }
  let(:list) do
    mock = Minitest::Mock.new
    mock.expect :tail, tail
    tail.expect(:append, nil) do |item|
      item.send :next=, tail
      item.send :prev=, head
      true
    end
    mock
  end

  describe '.new' do
    it 'accepts a value' do
      item = subject.new :value
      assert_equal :value, item.value
    end

    it 'accepts a list object responding to #tail' do
      item = nil

      assert_silent { item = subject.new list: list }

      list.verify
      tail.verify

      assert_same tail.object_id, item.next!.object_id
      assert_same head.object_id, item.prev!.object_id
    end
  end

  describe '#item' do
    it 'returns the item itself' do
      assert_same item, item.item
    end
  end

  describe '#list' do
    it 'returns the list the item is part of' do
      assert_same list.object_id, item_in_list.list.object_id
    end

    it 'raises an exception when the item is not in a list' do
      assert_raises(NoMethodError) { item.list }
    end
  end

  describe '#in_list?' do
    it 'returns true when the item is in a list' do
      assert item_in_list.in_list?
    end

    it 'returns false when the item is not in a list' do
        refute item.in_list?
      end
  end

  describe '#first?' do
    it 'returns true when there is no item before it' do
      item.append sibling
      assert item.first?
    end

    it 'returns false when there is an item before it' do
      item.prepend sibling
      refute item.first?
    end

    it 'returns true when first in a list' do
      head.expect :nil?, true
      assert item_in_list.first?
      head.verify
    end
  end

  describe '#last?' do
    it 'returns true when there is no item after it' do
      item.prepend sibling
      assert item.last?
    end

    it 'returns false when there is an item after it' do
      item.append sibling
      refute item.last?
    end

    it 'returns true when lasy in a list' do
      tail.expect :nil?, true
      assert item_in_list.last?
      tail.verify
    end
  end

  describe '#in?' do
    it 'returns true if the item is in the list' do
      list.expect :equal?, true, [list]
      item = subject.new list: list
      assert item.in?(list)
    end

    it 'returns false if the item is not in the list' do
      refute item.in?(list)
    end
  end
  
  describe '#==' do
    it 'returns true if the item value equals the others' do
      item.value = :value
      
      object = Minitest::Mock.new
      object.expect :value, :value
      
      assert_operator item, :==, object
      object.verify
    end
    
    it 'returns false if the item values does not equal the others' do
      item_a.value = :a
      item_b.value = :b
      refute_operator item_a, :==, item_b
    end
    
    it 'returns false if the other object does not respond to #value' do
      object = Minitest::Mock.new
      refute_operator item, :==, object
    end
    
    it 'is aliased to #eql?' do
      assert_equal item.method(:==), item.method(:eql?)
    end
  end

  describe '#next' do
    it 'returns the next item' do
      item.append sibling
      assert_same sibling, item.next
    end

    it 'raises an exception when there is no item after it' do
      item.prepend sibling
      assert_raises(StopIteration) { item.next }
    end
  end

  describe '#next!' do
    it 'returns the next item' do
      item.append sibling
      assert_same sibling, item.next
    end

    it 'returns nil when there is no item after it' do
      item.prepend sibling
      assert_nil item.next!
    end

    it 'returns the tail when last in a list' do
      assert_equal tail.object_id, item_in_list.next!.object_id
    end
  end

  describe '#prev' do
    it 'returns the previous item' do
      item.prepend sibling
      assert_same sibling, item.prev
    end

    it 'raises an exception when there is no item before it' do
      item.append sibling
      assert_raises(StopIteration) { item.prev }
    end

    it 'is aliased to #previous' do
      assert_equal item.method(:prev), item.method(:previous)
    end
  end

  describe '#prev!' do
    it 'returns the previous item' do
      item.prepend sibling
      assert_same sibling, item.prev
    end

    it 'returns nil when there is no item before it' do
      item.append sibling
      assert_nil item.prev!
    end

    it 'returns the head when first in a list' do
      assert_equal head.object_id, item_in_list.prev!.object_id
    end

    it 'is aliased to #previous!' do
      assert_equal item.method(:prev!), item.method(:previous!)
    end
  end

  describe '#list' do
    it 'returns the list if one was given' do
      item = subject.new list: list

      assert_equal list.object_id, item.list.object_id
    end
  end

  describe '#append' do
    it 'inserts an item after it' do
      item.append sibling
      assert_same sibling, item.next
    end

    it 'returns the item that was added' do
      assert_same sibling, item.append(sibling)
    end

    it 'inserts an item between two' do
      item_a.append item_c
      item_a.append item_b

      assert_same item_b, item_a.next
      assert_same item_b, item_c.prev
      assert_same item_a, item_b.prev
      assert_same item_c, item_b.next
    end

    it 'inserts multiple connected items' do
      item_b.append item_c
      ret = item_a.append item_b

      assert_same item_c, item_b.next
      assert_same item_c, ret
    end

    it 'accepts any object responding to #item' do
      list.expect :item, item_b
      item_a.append list
    end

    it 'only inserts the items after the given one' do
      item_a.append item_b
      item_b.append item_c

      item.append item_b

      assert item_a.last?
      assert_same item_b, item.next
    end

    it 'calls #prev= on tail and #incerment on the list when last in one' do
      list.expect :grow, nil, [1]
      tail.expect :prev=, nil, [sibling]

      item_in_list.append sibling

      tail.verify
      list.verify
      assert_equal sibling.next!.object_id, tail.object_id
    end

    it 'inserts multiple connected items when in a list' do
      list.expect :grow, nil, [2]
      tail.expect :prev=, nil, [item_c]

      item_b.append item_c
      item_in_list.append item_b

      list.verify
      tail.verify

      assert_equal list.object_id, item_c.list.object_id
    end

    it 'removes items already in a list from that list' do
      tail.expect :prev=, nil, [item_b]
      list.expect :grow, nil, [2]

      item_a.append item_b
      item_in_list.append item_a # grows the list by 2

      list.verify && tail.verify

      list.expect :shrink, nil, [2]
      tail.expect :nil?, true
      tail.expect :prev=, nil, [item_in_list]

      item.append item_a

      refute item.in_list?
      refute item_a.in_list?

      list.verify && tail.verify
    end

    it 'accepts a value' do
      item.append :value

      assert_kind_of subject, item.next
      assert_equal :value, item.next.value
    end

    it 'asks the list to create the item when given a value' do
      list.expect :create_item, item, [:value]
      list.expect :grow, nil
      tail.expect :prev=, nil, [item]

      item_in_list.append :value

      list.verify
    end
  end

  describe '#prepend' do
    it 'inserts an item before it' do
      item.prepend sibling
      assert_same sibling, item.prev
    end

    it 'returns the added item' do
      assert_same sibling, item.prepend(sibling)
    end

    it 'inserts an item between two' do
      item_a.append item_c
      item_c.prepend item_b

      assert_same item_b, item_a.next
      assert_same item_b, item_c.prev
      assert_same item_a, item_b.prev
      assert_same item_c, item_b.next
    end

    it 'inserts multiple connected items' do
      item_b.prepend item_a
      ret = item_c.prepend item_b

      assert_same item_a, item_b.prev
      assert_same item_a, ret
    end

    it 'accepts any object responding to #item' do
      list.expect :item, item_b
      item_a.prepend list
    end

    it 'only inserts the items before the given one' do
      item_a.append item_b
      item_b.append item_c

      item.prepend item_b

      assert item_c.first?
      assert_same item_b, item.prev
    end

    it 'calls #next= on head and #incerment on the list when first in one' do
      list.expect :grow, nil, [1]
      head.expect :next=, nil, [sibling]

      item_in_list.prepend sibling

      head.verify
      list.verify
      assert_equal sibling.prev!.object_id, head.object_id
    end

    it 'inserts multiple connected items when in a list' do
      list.expect :grow, nil, [2]
      head.expect :next=, nil, [item_a]

      item_b.prepend item_a
      item_in_list.prepend item_b

      list.verify
      head.verify

      assert_equal list.object_id, item_a.list.object_id
    end

    it 'removes items already in a list from that list' do
      head.expect :next=, nil, [item_a]
      list.expect :grow, nil, [2]

      item_a.append item_b
      item_in_list.prepend item_b # grows the list by 2

      list.verify && head.verify

      list.expect :shrink, nil, [2]
      head.expect :nil?, true
      head.expect :next=, nil, [item_in_list]

      item.prepend item_b

      refute item_a.in_list?
      refute item_b.in_list?

      list.verify && head.verify
    end

    it 'accepts a value' do
      item.prepend :value

      assert_kind_of subject, item.prev
      assert_equal :value, item.prev.value
    end

    it 'asks the list to create the item when given a value' do
      list.expect :create_item, item, [:value]
      list.expect :grow, nil
      head.expect :next=, nil, [item]

      item_in_list.prepend :value

      list.verify
    end
  end

  describe '#delete' do
    it 'does nothing for a single item' do
      assert_silent { item.delete }
    end

    it 'returns self' do
      assert_same item, item.delete
    end

    it 'removes the item from the end of a chain' do
      item_a.append item_b
      item_b.delete

      assert item_a.last?
    end

    it 'removes the item from the middles of a chain' do
      item_a.append item_b
      item_b.append item_c
      item_b.delete

      assert_same item_c, item_a.next
      assert_same item_a, item_c.prev
      assert_nil item_b.next!
      assert_nil item_b.prev!
    end

    it 'removes the item from the beginning of a chain' do
      item_b.append item_c
      item_b.delete

      assert item_c.first?
    end

    it 'calls #next= on head and #shrink on list when first in a list' do
      # First setup the item chain
      list.expect :grow, nil, [1]
      tail.expect :prev=, nil, [sibling]
      item_in_list.append sibling

      list.expect :shrink, nil
      head.expect :next=, nil, [sibling]
      item_in_list.delete
      head.verify
      list.verify
    end

    it 'calls #prev= on tail when last in a list' do
      # First setup the item chain
      list.expect :grow, nil, [1]
      head.expect :next=, nil, [sibling]
      item_in_list.prepend sibling

      list.expect :shrink, nil
      tail.expect :prev=, nil, [sibling]
      item_in_list.delete
      tail.verify
      list.verify
    end

    it 'calls both #next= and #prev= when deleting a single item' do
      list.expect :shrink, nil
      head.expect :next=, nil, [tail]
      tail.expect :prev=, nil, [head]
      item_in_list.delete
      head.verify
      tail.verify
      list.verify
    end
  end

  describe '#delete_before' do
    before do
      item_a.append(item_b).append(item_c)
    end

    it 'returns nil when nothing is removed' do
      assert_nil item_a.delete_before
      assert_same item_b, item_a.next
    end

    it 'returns the first item in the deleted chain' do
      assert_same item_a, item_c.delete_before
      assert_nil item_b.next!
      assert_nil item_c.prev!
    end

    it 'removes items from a list' do
      head.expect :next=, nil, [item_a]
      list.expect :grow, nil, [2]

      item_in_list.prepend item_b # grows the list by 2

      assert item_a.in_list?
      assert item_b.in_list?

      list.verify && head.verify

      list.expect :shrink, nil, [2]
      head.expect :nil?, true
      head.expect :next=, nil, [item_in_list]

      item_in_list.delete_before

      refute item_a.in_list?
      refute item_b.in_list?

      list.verify && head.verify
    end
  end

  describe '#delete_after' do
    before do
      item_a.append(item_b).append(item_c)
    end

    it 'returns nil when nothing is removed' do
      assert_nil item_c.delete_after
      assert_same item_b, item_c.prev
    end

    it 'returns the last item in the deleted chain' do
      assert_same item_c, item_a.delete_after
      assert_nil item_a.next!
      assert_nil item_b.prev!
    end

    it 'removes items from a list' do
      tail.expect :prev=, nil, [item_c]
      list.expect :grow, nil, [2]

      item_in_list.append item_b # grows the list by 2

      assert item_b.in_list?
      assert item_c.in_list?

      list.verify && tail.verify

      list.expect :shrink, nil, [2]
      tail.expect :nil?, true
      tail.expect :prev=, nil, [item_in_list]

      item_in_list.delete_after

      refute item_b.in_list?
      refute item_c.in_list?

      list.verify && head.verify
    end
  end

  describe '#before' do
    it 'returns an enumerator' do
      assert_kind_of Enumerator, item.before
    end

    it 'iterates over the items' do
      item_a.append item_b
      item_b.append item_c

      res = []
      item_c.before { |item| res << item }

      assert_same item_b, res[0]
      assert_same item_a, res[1]
      assert_equal 2, res.length
    end
  end

  describe '#after' do
    it 'returns an enumerator' do
      assert_kind_of Enumerator, item.after
    end

    it 'iterates over the items' do
      item_a.append item_b
      item_b.append item_c

      res = []
      item_a.after { |item| res << item }

      assert_same item_b, res[0]
      assert_same item_c, res[1]
      assert_equal 2, res.length
    end
  end

  describe '#dup' do
    it 'disconnects the new item from its siblings' do
      item_a.append(item_b).append(item_c)
      duped_item = item_b.dup

      assert_nil duped_item.prev!
      assert_nil duped_item.next!
    end

    it 'disconects the new item from its list' do
      list.expect :grow, nil, [2]
      tail.expect :prev=, nil, [item_c]

      item_b.append item_c
      item_in_list.append item_b

      refute item_b.dup.in_list?
    end

    it 'calls #dup on the value' do
      value = Minitest::Mock.new
      value.expect :dup, nil

      item.value = value
      item.dup

      value.verify
    end

    it 'accepts undupable values' do
      value = Minitest::Mock.new
      value.expect(:dup, nil) { raise TypeError }

      item.value = value
      item.dup
    end
  end

  describe '#freeze' do
    it 'freezes the value' do
      item.value = 'mutable'
      item.freeze

      assert_raises(RuntimeError) { item.value.chop! }
    end
  end

  describe '#inspect' do
    it 'includes the class name' do
      refute_nil item.inspect[item.class.name]
    end

    it 'includes the object id' do
      hex_id = format '0x%0x', item.object_id
      refute_nil item.inspect[hex_id]
    end

    it 'includes the value unless it is nil' do
      assert_nil item.inspect['value=']
      item.value = 'value'
      refute_nil item.inspect['value="value"']
    end

    it 'accepts a block' do
      item.value = 'inspected'
      res = item.inspect { |itm| itm.value }

      assert_equal item.value, res
    end
  end
end
