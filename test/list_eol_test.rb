require 'test_helper'

describe Linked::List::EOL do
  subject { Linked::List::EOL }
  
  let(:list) { Minitest::Mock.new }
  let(:item) { Linked::Item.new }
  let(:item_a) { Linked::Item.new }
  let(:item_b) { Linked::Item.new }
  let(:eol) { subject.new list: list }
  let(:eol_with_item) { list.expect :grow, nil, [1]; eol.append item; eol }
  let(:eol_whit_items) do
    item_a.append item_b
    list.expect :grow, nil, [2]
    eol.append item_a
    eol
  end
  
  describe '#first?' do
    it 'is private' do
      assert eol.private_methods.include?(:first?)
    end
    
    it 'returns true when there are no items' do
      assert eol.send :first?
    end
    
    it 'returns false when there are items' do
      refute eol_with_item.send :first?
    end
  end
  
  describe '#last?' do
    it 'is private' do
      assert eol.private_methods.include?(:last?)
    end

    it 'returns true' do
      assert eol.send :last?
    end
    
    it 'returns false when there are items' do
      refute eol_with_item.send :last?
    end
  end

  describe '#nil?' do
    it 'returns true' do
      assert eol.nil?
    end
  end
  
  describe '#next' do
    it 'returns the first item' do
      assert_same item_a, eol_whit_items.next
    end
  end
  
  describe '#prev' do
    it 'returns the last item' do
      assert_same item_b, eol_whit_items.prev
    end
  end

  describe '#append' do
    it 'inserts an item when it is empty' do
      list.expect :grow, nil, [1]
      eol.append item
      
      assert_same item, eol.prev
      assert_same item, eol.next
      list.verify
    end
    
    it 'inserts an item when it is not empty' do
      list.expect :grow, nil, [1]
      eol.append item_a
      
      list.expect :grow, nil, [1]
      eol.append item_b
      
      assert_same item_b, eol.prev
      assert_same item_a, eol.next
    end
  end
  
  describe '#prepend' do
    it 'inserts an item when it is empty' do
      list.expect :grow, nil, [1]
      eol.prepend item
      
      assert_same item, eol.prev
      assert_same item, eol.next
      list.verify
    end
    
    it 'inserts an item when it is not empty' do
      list.expect :grow, nil, [1]
      eol.prepend item_b
      
      list.expect :grow, nil, [1]
      eol.prepend item_a
      
      assert_same item_b, eol.prev
      assert_same item_a, eol.next
    end
  end
end
