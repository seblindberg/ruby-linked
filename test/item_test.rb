require 'test_helper'

describe Linked::Item do
  subject { ::Linked::Item }
  
  let(:item) { subject.new }
  let(:item_in_list) { subject.new list: list }
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
  
  describe '#split' do
    before do
      item_a.append(item_b).append(item_c)
    end
    
    it 'returns self' do
      assert_same item, item.split
    end
    
    it 'does nothing on the first item' do
      assert_same item_a, item_a.split
      assert_same item_b, item_a.next
    end
    
    it 'does nothing on the last item with after: true' do
      assert_same item_c, item_c.split(after: true)
      assert_same item_b, item_c.prev
    end
    
    it 'splits a chain of items in two' do
      assert_same item_b, item_b.split
      assert_nil item_a.next!
      assert_nil item_b.prev!
      assert_same item_c, item_b.next
      assert_same item_b, item_c.prev
    end
    
    it 'splits after the item with after: true' do
      assert_same item_b, item_b.split(after: true)
      assert_same item_b, item_a.next
      assert_same item_a, item_b.prev
      assert_nil item_c.prev!
      assert_nil item_b.next!
    end
    
    it 'removes the items before when in a list' do
      item_a = subject.new list: list
      
      list.expect :grow, nil, [2]
      tail.expect :prev=, nil, [item_c]
      
      item_a.append item_b # which is already linked to item_c
      list.verify
      tail.verify
      
      # Now a, b and c are part of a list
      
      list.expect :head, head
      list.expect :shrink, nil, [1]
      head.expect :nil?, true
      head.expect :next=, nil, [item_b]
      
      item_b.split
      
      list.verify
      head.verify
      
      assert_nil item_a.list
    end
    
    it 'removes the items after when in a list and after: true' do
      item_a = subject.new list: list
      
      list.expect :grow, nil, [2]
      tail.expect :prev=, nil, [item_c]
      
      item_a.append item_b # which is already linked to item_c
      list.verify
      tail.verify
      
      # Now a, b and c are part of a list
      
      list.expect :tail, tail
      list.expect :shrink, nil, [1]
      tail.expect :nil?, true
      tail.expect :prev=, nil, [item_b]
      
      item_b.split after: true
      
      list.verify
      tail.verify
      
      assert_nil item_c.list
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
    
    it 'accepts a value' do
      item.append :value
      assert_equal :value, item.next.value
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
    
    it 'accepts a value' do
      item.prepend :value
      assert_equal :value, item.prev.value
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
      
      assert_nil item_b.dup.list
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
