require 'test_helper'

describe Linked::List do
  subject { ListLike }
  
  let(:list) { subject.new }
  let(:item) { Linked::Item.new }
  
  let(:item_a) { Linked::Item.new }
  let(:item_b) { Linked::Item.new }
  
  it 'includes Enumerable' do
    assert subject.ancestors.include? Enumerable
  end
  
  describe '#first' do
    it 'returns nil for empty lists' do
      assert_nil list.first
    end
    
    it 'returns the first item' do
      list.push item
      assert_same item, list.first
    end
    
    it 'supports fetching multiple items' do
      list.push item_a
      list.push item_b
      
      res = list.first 2
      
      assert_same item_a, res[0]
      assert_same item_b, res[1]
    end
    
    it 'only returns the maximum number of items' do
      list.push item_a
      list.push item_b
      
      res = list.first 3
      
      assert_equal 2, res.length
    end
  end
  
  describe '#last' do
    it 'returns nil for empty lists' do
      assert_nil list.last
    end
    
    it 'returns the first item' do
      list.push item
      assert_same item, list.last
    end
    
    it 'returns an empty array when given 0' do
      assert_equal [], list.last(0)
    end
    
    it 'supports fetching multiple items' do
      list.push item_a
      list.push item_b
      
      res = list.last 2
      
      assert_same item_a, res[0]
      assert_same item_b, res[1]
    end
    
    it 'only returns the maximum number of items' do
      list.push item_a
      list.push item_b
      
      res = list.last 3
      
      assert_equal 2, res.length
    end
    
    it 'raises an ArgumentError for negative ammounts' do
      assert_raises(ArgumentError) { list.last(-1) }
    end
  end
  
  describe '#count' do
    it 'returns the number of items' do
      list.push item_a
      list.push item_b

      assert_equal 2, list.count
    end
    
    it 'accepts an argument' do
      list.push item_a
      list.push item_b
      
      assert_equal 1, list.count(item_b)
    end
    
    it 'accepts a block' do
      item_a.value = 1
      item_b.value = 2
      
      list.push item_a
      list.push item_b
      
      count = list.count { |item| item.value > 1 }
      
      assert_equal 1, count
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
    
    it 'accepts an arbitrary value' do
      list.push :value_1
      list.push :value_2
      
      assert_equal :value_1, list.first.value
      assert_equal :value_2, list.last.value
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
    
    it 'accepts an arbitrary value' do
      list.unshift :value_1
      list.unshift :value_2
      
      assert_equal :value_2, list.first.value
      assert_equal :value_1, list.last.value
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
  
  describe '#each_item' do
    before do
      list.push item_a
      list.push item_b
    end
    
    it 'iterates over each item' do
      res = []
      list.each { |item| res << item }
      
      assert_same item_a, res.first
      assert_same item_b, res.last
    end
    
    it 'iterates over each item in reverse' do
      res = []
      list.each(reverse: true) { |item| res << item }
      
      assert_same item_b, res.first
      assert_same item_a, res.last
    end
  end
  
  describe '#dup' do
    before do
      item_a.value = 'a'

      list.push item_a
      list.push item_b
    end
    
    it 'copies the entire chain of items' do
      duped_list = list.dup
      
      refute_same item_a, duped_list.first
      refute_same item_b, duped_list.last
      
      assert_equal item_a.value, duped_list.first.value
      refute_same item_a.value, duped_list.first.value
    end
  end
end
