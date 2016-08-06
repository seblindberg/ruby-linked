require 'test_helper'

describe Linked::List::EOL do
  subject { Linked::List::EOL }
  
  let(:list) { Minitest::Mock.new }
  let(:eol) { subject.new list: list }
  let(:item) { Linked::Item.new }
  let(:item_a) { Linked::Item.new }
  let(:item_b) { Linked::Item.new }

  describe '#nil?' do
    it 'returns true' do
      assert eol.nil?
    end
  end

  describe '#append' do
    it 'inserts an item when it is empty' do
      list.expect :increment, nil, [1]
      eol.append item
      
      assert_same item, eol.prev
      assert_same item, eol.next
      list.verify
    end
    
    it 'inserts an item when it is not empty' do
      list.expect :increment, nil, [1]
      eol.append item_a
      
      list.expect :increment, nil, [1]
      eol.append item_b
      
      assert_same item_b, eol.prev
      assert_same item_a, eol.next
    end
    
    it 'inserts a string of items' do
      item_a.append item_b
      list.expect :increment, nil, [2]
      eol.append item_a
      
      assert_same item_b, eol.prev
      assert_same item_a, eol.next
      list.verify
    end
  end
  
  describe '#prepend' do
    it 'inserts an item when it is empty' do
      list.expect :increment, nil, [1]
      eol.prepend item
      
      assert_same item, eol.prev
      assert_same item, eol.next
      list.verify
    end
    
    it 'inserts an item when it is not empty' do
      list.expect :increment, nil, [1]
      eol.prepend item_b
      
      list.expect :increment, nil, [1]
      eol.prepend item_a
      
      assert_same item_b, eol.prev
      assert_same item_a, eol.next
    end
    
    it 'inserts a string of items' do
      item_b.prepend item_a
      list.expect :increment, nil, [2]
      eol.prepend item_b
      
      assert_same item_b, eol.prev
      assert_same item_a, eol.next
      list.verify
    end
  end
  
  describe '#before' do
    it 'returns an empty iterator when it contains no items' do
      enum = eol.before
      assert_raises(StopIteration) { enum.next }
    end
    
    it 'iterates over all items in reverse' do
      list.expect :increment, nil, [1]
      eol.append item_a
      list.expect :increment, nil, [1]
      eol.append item_b

      res = eol.before.to_a

      assert_same item_b, res.first
      assert_same item_a, res.last
    end
  end
  
  describe '#after' do
    it 'returns an empty iterator when it contains no items' do
      enum = eol.after
      assert_raises(StopIteration) { enum.next }
    end
      
    it 'iterates over all items' do
      list.expect :increment, nil, [1]
      eol.append item_a
      list.expect :increment, nil, [1]
      eol.append item_b
      
      res = eol.after.to_a
      
      assert_same item_a, res.first
      assert_same item_b, res.last
    end
  end
end
