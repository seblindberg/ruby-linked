require 'test_helper'

class Item
  include Linked::Listable
  
  attr_reader :args
  
  def initialize(*args)
    @args = args
    super()
  end
end

describe Linked::Listable do
  subject { ::Item }

  let(:item) { subject.new }
  
  let(:item_a) { subject.new }
  let(:item_b) { subject.new }
  let(:item_c) { subject.new }

  let(:sibling) { subject.new }
  
  let(:lookup) do
    Hash.new { |h, k| h.fetch(k.object_id, k) }.tap do |h|
      h.merge!({
        item.object_id => 'item',
        sibling.object_id => 'sibling',
        item_a.object_id => 'item_a',
        item_b.object_id => 'item_b',
        item_c.object_id => 'item_c',
      })
    end
  end
  
  before do
    item_a.append(item_b).append(item_c)
  end
  
  describe '#item' do
    it 'returns the object itself' do
      assert_same item, item.item
    end
  end
  
  describe '#first?' do
    it 'returns true when there is no item before it' do
      assert item_a.first?
    end

    it 'returns false when there is an item before it' do
      refute item_b.first?
    end
  end

  describe '#last?' do
    it 'returns true when there is no item after it' do
      assert item_c.last?
    end

    it 'returns false when there is an item after it' do
      refute item_b.last?
    end
  end

  describe '#chain_head' do
    it 'returns the item iteself if it is first' do
      assert_same item_a, item_a.chain_head
    end
      
    it 'returns the first item in the chain' do
      assert_same item_a, item_b.chain_head
    end
    
    it 'is aliased to #chain' do
      assert_equal item.method(:chain_head), item.method(:chain)
    end
  end

  describe '#last' do
    it 'returns the item iteself if it is last' do
      assert_same item_c, item_c.chain_tail
    end
      
    it 'returns the last item in the chain' do
      assert_same item_c, item_b.chain_tail
    end
  end

  describe '#chain_length' do
    it 'returns 1 for single items' do
      assert_equal 1, item.chain_length
    end
  end
  
  describe '#===' do
    it 'returns true if the items are in the same chain' do
      assert_operator item_a, :===, item_b
    end
    
    it 'returns false if the items are not in the same chain' do
      refute_operator item_a, :===, item
    end
    
    it 'returns false for arbitrary objects' do
      refute_operator item_a, :===, :no_item
    end
  end

  describe '#next' do
    it 'returns the next item' do
      item.append sibling
      assert_same sibling, item.next
    end

    it 'raises an exception when there is no item after it' do
      sibling.append item
      assert_raises(StopIteration) { item.next }
    end
  end

  describe '#prev' do
    it 'returns the previous item' do
      sibling.append item
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

  describe '#append' do
    it 'inserts an item after it' do
      item.append sibling # I <> S
      assert_chain item, sibling
    end
    
    it 'inserts multiple connected items' do
      item.append item_a # I <> A <> B <> C
      assert_chain item, item_a, item_b, item_c
    end

    it 'returns the last item that was added' do
      assert_same item_c, item.append(item_a)
    end

    it 'inserts an item between two' do
      item_a.append item # A <> I <> B <> C
      assert_chain item_a, item, item_b, item_c
    end

    it 'accepts any object responding to #item' do
      object = Minitest::Mock.new
      object.expect :item, sibling
      item.append object
      assert_chain item, sibling
    end

    it 'only inserts the items after the given one' do
      item.append item_b # A | I <> B <> C

      assert_chain item_a
      assert_chain item, item_b, item_c
    end
    
    it 'accepts an arbitrary object' do
      item.append :argument
  
      assert_kind_of subject, item.next
      assert_equal [:argument], item.next.args
    end
  end

  describe '#prepend' do
    it 'inserts an item before it' do
      item.prepend sibling  # S <> I
      assert_chain sibling, item
    end
    
    it 'inserts multiple connected items' do
      item.prepend item_c  # A <> B <> C <> I
      assert_chain item_a, item_b, item_c, item
    end
    
    it 'returns the first item in the added chain' do
      assert_same item_a, item.prepend(item_c)
    end
    
    it 'inserts an item between two' do
      item_c.prepend item
      assert_chain item_a, item_b, item, item_c
    end
    
    it 'accepts any object responding to #item' do
      object = Minitest::Mock.new
      object.expect :item, sibling
      
      item.prepend object
      assert_chain sibling, item
    end
    
    it 'only inserts the items before the given one' do
      item.prepend item_b # A <> B <> I | C
      
      assert_chain item_a, item_b, item
      assert_chain item_c
    end
    
    it 'accepts an arbitrary object' do
      item.prepend :argument
    
      assert_kind_of subject, item.prev
      assert_equal [:argument], item.prev.args
    end
  end

  describe '#delete' do
    it 'does nothing for a single item' do
      item.delete
    end
    
    it 'returns self' do
      assert_same item, item.delete
    end
    
    it 'removes the item from the end of a chain' do
      item_c.delete
      
      assert_chain item_a, item_b
      assert_chain item_c
    end
    
    it 'removes the item from the middles of a chain' do
      item_b.delete
    
      assert_chain item_a, item_c
      assert_chain item_b
    end
    
    it 'removes the item from the beginning of a chain' do
      item_a.delete
      
      assert_chain item_a
      assert_chain item_b, item_c
    end
  end

  describe '#delete_before' do
    it 'returns nil when nothing is removed' do
      assert_nil item_a.delete_before
      assert_chain item_a, item_b, item_c
    end
    
    it 'returns the first item in the deleted chain' do
      assert_same item_a, item_c.delete_before
    end
    
    it 'deletes the items before' do
      item_c.delete_before
      
      assert_chain item_a, item_b
      assert_chain item_c
    end
  end

  describe '#delete_after' do
    it 'returns nil when nothing is removed' do
      assert_nil item_c.delete_after
      assert_chain item_a, item_b, item_c
    end
    
    it 'returns the first item in the deleted chain' do
      assert_same item_b, item_a.delete_after
    end
    
    it 'deletes the items after' do
      item_a.delete_after
      
      assert_chain item_a
      assert_chain item_b, item_c
    end
  end

  describe '#before' do
    it 'returns an enumerator' do
      assert_kind_of Enumerator, item.before
    end
    
    it 'iterates over the items' do
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
      res = []
      item_a.after { |item| res << item }
    
      assert_same item_b, res[0]
      assert_same item_c, res[1]
      assert_equal 2, res.length
    end
  end
  
  describe '#take' do
    it 'returns an empty array when n = 0' do
      assert_equal [], item.take(0)
    end
    
    it 'raises an error unless n is a whole number' do
      assert_raises(ArgumentError) { item.take 0.1 }
      assert_raises(ArgumentError) { item.take :a }
      assert_silent { item.take 1 }
    end
    
    it 'returns an array with a single item when |n| = 0' do
      assert_equal [item], item.take(1)
      assert_equal [item], item.take(-1)
    end
    
    it 'returns an array with itself and the items after' do
      assert_equal [item_a, item_b], item_a.take(2)
    end
    
    it 'returns an array with itself and the items before' do
      assert_equal [item_a, item_b], item_b.take(-2)
    end
    
    it 'returns an array shorter than n if there are less than n items' do
      assert_equal [item_a, item_b, item_c], item_a.take(4)
      assert_equal [item_a, item_b, item_c], item_c.take(-4)
    end
  end

  describe '#dup' do
    it 'disconnects the new item from its siblings' do
      assert_chain item_b.dup
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
  end
end
