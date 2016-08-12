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
  
  # The following tests all describe the behaviour of a Listable item outside of
  # a list. Items within lists are tested further down below.

  describe '#item' do
    it 'returns the item itself' do
      assert_same item, item.item
    end
  end

  describe '#list' do
    it 'raises a NoMethodError' do
      assert_raises(NoMethodError) { item.list }
    end
  end

  describe '#in_list?' do
    it 'returns false' do
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
  end

  describe '#in?' do
    it 'returns false if the item is not in a list' do
      list = Minitest::Mock.new
      refute item.in?(list)
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
      object = Minitest::Mock.new
      object.expect :item, item_b
      item_a.append object
      assert_same item_b, item_a.next
    end

    it 'only inserts the items after the given one' do
      item_a.append item_b
      item_b.append item_c

      item.append item_b

      assert item_a.last?
      assert_same item_b, item.next
    end

    it 'accepts an argument' do
      item.append :argument

      assert_kind_of subject, item.next
      assert_equal [:argument], item.next.args
    end
    
    it 'accepts an arbitrary object' do
      item.append :argument
  
      assert_kind_of subject, item.next
      assert_equal [:argument], item.next.args
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
      object = Minitest::Mock.new
      object.expect :item, item_b
      item_a.prepend object
      assert_same item_b, item_a.prev
    end

    it 'only inserts the items before the given one' do
      item_a.append item_b
      item_b.append item_c

      item.prepend item_b

      assert item_c.first?
      assert_same item_b, item.prev
    end

    it 'accepts an arbitrary object' do
      item.prepend :argument
      
      assert_kind_of subject, item.prev
      assert_equal [:argument], item.prev.args
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
      assert item_b.first?
      assert item_b.last?
    end

    it 'removes the item from the beginning of a chain' do
      item_b.append item_c
      item_b.delete

      assert item_c.first?
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
      assert item_b.last?
      assert item_c.first?
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
      assert item_a.last?
      assert item_b.first?
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

      assert duped_item.first?
      assert duped_item.last?
    end
  end
  
  # The following tests all apply to listeable items interacting with lists.
  
  describe 'in list' do
    let(:item_in_list) { subject.new.tap { |s| list.append s } }
    let(:head) { Minitest::Mock.new }
    let(:tail) { Minitest::Mock.new }
    let(:list) do
      mock = Minitest::Mock.new
      mock.expect(:append, nil) do |item|
        item.send :list=, mock
        item.send :next=, tail
        item.send :prev=, head
        true
      end
      mock
    end
    
    describe '#list' do
      it 'returns the list' do
        assert_same list.object_id, item_in_list.list.object_id
      end
    end

    describe '#in_list?' do
      it 'returns true' do
        assert item_in_list.in_list?
      end
    end

    describe '#first?' do
      it 'returns true when first' do
        head.expect :nil?, true
        assert item_in_list.first?
        head.verify
      end
    end

    describe '#last?' do
      it 'returns true when last' do
        tail.expect :nil?, true
        assert item_in_list.last?
        tail.verify
      end
    end

    describe '#in?' do
      it 'returns true if the item is in the list' do
        list.expect :equal?, true, [list]
        list.append item
        assert item.in?(list)
      end
    end

    describe '#append' do
      it 'calls #prev= on tail and #grow on the list' do
        list.expect :grow, nil, [1]
        tail.expect :prev=, nil, [sibling]

        item_in_list.append sibling

        tail.verify
        list.verify
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

      it 'inserts multiple connected items' do
        list.expect :grow, nil, [2]
        tail.expect :prev=, nil, [item_c]

        item_b.append item_c
        item_in_list.append item_b

        list.verify
        tail.verify

        assert_equal list.object_id, item_c.list.object_id
      end

      it 'asks the list to create an item when given an object' do
        item_in_list && list.verify

        list.expect :create_item, item, [:value]
        list.expect :grow, nil
        tail.expect :prev=, nil, [item]

        item_in_list.append :value

        list.verify
      end
    end

    describe '#prepend' do
      it 'calls #next= on head and #grow on the list' do
        list.expect :grow, nil, [1]
        head.expect :next=, nil, [sibling]
        head.expect :nil?, true

        item_in_list.prepend sibling
        assert sibling.first?

        head.verify
        list.verify
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

      it 'inserts multiple connected items' do
        list.expect :grow, nil, [2]
        head.expect :next=, nil, [item_a]

        item_b.prepend item_a
        item_in_list.prepend item_b

        list.verify
        head.verify

        assert_equal list.object_id, item_a.list.object_id
      end

      it 'asks the list to create an item when given an object' do
        list.expect :create_item, item, [:value]
        list.expect :grow, nil
        head.expect :next=, nil, [item]

        item_in_list.prepend :value

        list.verify
      end
    end
    
    describe 'deleting' do
      before do
        list.expect :grow, nil, [1]
        head.expect :next=, nil, [item_a]
        
        item_in_list.prepend item_a
        list.verify && head.verify
        
        list.expect :grow, nil, [1]
        tail.expect :prev=, nil, [item_b]
        
        item_in_list.append item_b
        list.verify && tail.verify
      end

      describe '#delete' do
        it 'calls #shrink on the list' do
          list.expect :shrink, nil
          item_in_list.delete
          list.verify
        end
        
        it 'calls #next= on head when first' do
          list.expect :shrink, nil
          head.expect :next=, nil, [item_in_list]
          item_a.delete
          head.verify && list.verify
        end
  
        it 'calls #prev= on tail when last' do
          list.expect :shrink, nil
          tail.expect :prev=, nil, [item_in_list]
          item_b.delete
          tail.verify && list.verify
        end
      end
  
      describe '#delete_before' do
        it 'removes items from a list' do
          list.expect :shrink, nil, [2]
          head.expect :nil?, true
          head.expect :next=, nil, [item_b]
  
          item_b.delete_before
  
          refute item_a.in_list?
          list.verify && head.verify
        end
      end
  
      describe '#delete_after' do
        it 'removes items from a list' do
          list.expect :shrink, nil, [2]
          tail.expect :nil?, true
          tail.expect :prev=, nil, [item_a]
  
          item_a.delete_after
  
          refute item_b.in_list?
          list.verify && head.verify
        end
      end
    end

    describe '#dup' do
      it 'disconects the new item from its list' do
        refute item_in_list.dup.in_list?
      end
    end
  end
end
