require 'test_helper'

describe Linked::List do
  subject { Linked::List }
  
  let(:list) { subject.new }
  let(:item) { Linked::Item.new }
  
  let(:item_a) { Linked::Item.new }
  let(:item_b) { Linked::Item.new }
  
  describe '#first' do
    it 'returns nil for empty lists' do
      assert_nil list.first
    end
  end
  
  describe '#last' do
    it 'returns nil for empty lists' do
      assert_nil list.last
    end
  end
  
  describe '#push' do
    it 'inserts an item in an empty list' do
      list.push item
      
      assert_same list, item.list
      assert_nil item.prev!
      assert_nil item.next!
      assert_equal 1, list.count
    end
    
    it 'returns self' do
      ret = list.push item
      assert_same list, ret
    end
    
    it 'inserts multiple items' do
      list.push item_a
      list.push item_b
      
      assert_same item_b, item_a.next
      assert_same item_a, item_b.prev
      assert_equal 2, list.count
    end
    
    it 'inserts a string of items' do
      item_a.append item_b
      list.push item_a
      
      assert_equal 2, list.count
    end
    
    it 'is aliased to #<<' do
      assert_equal list.method(:push), list.method(:<<)
    end
  end
  
  describe '#pop' do
    it 'removes the last Item' do
      list.push item_a
      list.push item_b
      list.pop
      
      assert_nil item_a.next!
      assert_equal 1, list.count
    end
    
    it 'returns the removed item' do
      list.push item_a
      list.push item_b
      
      assert_same item_b, list.pop
    end
    
    it 'leaves the list empty' do
      list.push item
      list.pop
      
      assert_nil list.first
      assert_nil list.last
      assert_equal 0, list.count
    end
    
    it 'returns nil for empty lists' do
      assert_nil list.pop
    end
  end
  
  describe 'unshift' do
    it 'inserts an item in an empty list' do
      list.unshift item
      
      assert_same list, item.list
      assert_nil item.prev!
      assert_nil item.next!
      assert_equal 1, list.count
    end
    
    it 'returns self' do
      ret = list.unshift item
      assert_same list, ret
    end
    
    it 'inserts multiple items' do
      list.unshift item_b
      list.unshift item_a
      
      assert_same item_b, item_a.next
      assert_same item_a, item_b.prev
      assert_equal 2, list.count
    end
    
    it 'inserts a string of items' do
      item_b.prepend item_a
      list.unshift item_b
      
      assert_equal 2, list.count
    end
  end
  
  describe '#shift' do
    it 'removes the first item' do
      list.push item_a
      list.push item_b
      list.shift

      assert_nil item_b.prev!
      assert_equal 1, list.count
    end

    it 'returns the removed item' do
      list.push item_a
      list.push item_b

      assert_same item_a, list.shift
    end

    it 'leaves the list empty' do
      list.push item
      list.shift

      assert_nil list.first
      assert_nil list.last
      assert_equal 0, list.count
    end
    
    it 'returns nil for empty lists' do
      assert_nil list.shift
    end
  end
end
