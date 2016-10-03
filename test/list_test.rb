require 'test_helper'

describe Linked::List do
  subject { Linked::List }

  let(:list) { subject.new }
  let(:item) { Linked::Item.new }

  let(:item_a) { Linked::Item.new :a }
  let(:item_b) { Linked::Item.new :b }

  it 'includes Enumerable' do
    assert subject.ancestors.include? Enumerable
  end
  
  describe '#item' do
    it 'returns the first item in the list' do
      list << item
      assert_same item, list.item
    end
  
    it 'raises an exception when list is empty' do
      assert_raises(NoMethodError) { list.item }
    end
  end
  
  describe '#==' do
    let(:list_a) do
      item_a.value = :value
      item_b.value = :value
      list << item_a << item_b
    end
    let(:list_b) { list_a.dup }
    
    it 'returns false if the other object is not a list' do
      object = Minitest::Mock.new
      object.expect :is_a?, false, [subject]
      refute_operator list, :==, object
      object.verify
    end
    
    it 'returns true for lists with items with equal values' do
      refute_same list_a, list_b
      assert_equal list_a, list_b
    end
    
    it 'returns false for lists with items that are not equal' do
      list_b.last.value = :not_value
      refute_equal list_a, list_b
    end
    
    it 'returns false for lists of unequal length' do
      list_b.pop
      refute_equal list_a, list_b
    end
  end
  
  describe '#empty?' do
    it 'returns true for empty lists' do
      assert_predicate list, :empty?
    end
    
    it 'returns false for non-empty lists' do
      list << item
      refute_predicate list, :empty?
    end
    
    it 'returns false when items override #==' do
      item.define_singleton_method(:==) { |_| true }
      list << item
      refute_predicate list, :empty?
    end
  end

  describe '#first' do
    describe 'with no argument' do
      it 'returns nil for empty lists' do
        assert_nil list.first
      end
      
      it 'returns the first item' do
        list.push item
        assert_same item, list.first
      end
    end
    
    describe 'with argument n' do
      it 'returns an empty array when n = 0' do
        assert_equal [], list.first(0)
      end
      
      it 'raises an error if n < 0' do
        assert_raises(ArgumentError) { list.first(-1) }
      end
      
      it 'returns an empty array for empty lists when n > 0' do
        assert_equal [], list.first(1)
      end
      
      it 'returns the first n items' do
        list.push item_a
        list.push item_b
        
        res = list.first 2
        
        assert_same item_a, res[0]
        assert_same item_b, res[1]
      end
      
      it 'only returns the available items' do
        list.push item_a
        list.push item_b
        
        res = list.first 3
  
        assert_equal 2, res.length
      end
    end
  end

  describe '#last' do
    describe 'with no argument' do
      it 'returns nil for empty lists' do
        assert_nil list.last
      end
      
      it 'returns the first item' do
        list.push item
        assert_same item, list.last
      end
    end
    
    describe 'with argument n' do
      it 'returns an empty array when n = 0' do
        assert_equal [], list.last(0)
      end
      
      it 'raises an error if n < 0' do
        assert_raises(ArgumentError) { list.last(-1) }
      end
      
      it 'returns an empty array for empty lists when n > 0' do
        assert_equal [], list.last(1)
      end
      
      it 'returns the last n items' do
        list.push item_a
        list.push item_b
        
        res = list.last 2
        
        assert_same item_a, res[0]
        assert_same item_b, res[1]
      end
      
      it 'only returns the available items' do
        list.push item_a
        list.push item_b
        
        res = list.last 3
  
        assert_equal 2, res.length
      end
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
      assert_list_contains list, item
    end

    it 'returns self' do
      assert_same list, list.push(item)
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
      
      assert_list_contains list, item_a, item_b
    end

    it 'inserts a string of items' do
      item_a.append item_b
      list.push item_a

      assert_list_contains list, item_a, item_b
    end

    it 'is aliased to #<<' do
      assert_equal list.method(:push), list.method(:<<)
    end
  end

  describe '#pop' do
    before do
      list << item_a << item_b
    end
    
    it 'removes the last Item' do
      list.pop
      assert_list_contains list, item_a
      assert_chain item_b
    end

    it 'returns the removed item' do
      assert_same item_b, list.pop
    end

    it 'leaves the list empty' do
      list.pop
      list.pop
      
      assert_equal 0, list.count
    end

    it 'returns nil for empty lists' do
      assert_nil subject.new.pop
    end
  end

  describe 'unshift' do
    it 'inserts an item in an empty list' do
      list.unshift item
      assert_list_contains list, item
    end

    it 'returns self' do
      assert_same list, list.unshift(item)
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
      
      assert_list_contains list, item_a, item_b
    end

    it 'inserts a string of items' do
      item_a.append item_b
      list.unshift item_b

      assert_list_contains list, item_a, item_b
    end
  end

  describe '#shift' do
    before { list << item_a << item_b }
    
    it 'removes the first item' do
      list.shift
      assert_list_contains list, item_b
      assert_chain item_a
    end

    it 'returns the removed item' do
      assert_same item_a, list.shift
    end

    it 'leaves the list empty' do
      list.shift
      list.shift

      assert list.empty?
    end

    it 'returns nil for empty lists' do
      assert_nil subject.new.shift
    end
  end
  
  describe '#include?' do
    before { list << item_a }
    
    it 'returns true when the item is in the list' do
      assert list.include?(item_a)
    end
    
    it 'returns false when the item is not in the list' do
      refute list.include?(item_b)
    end
    
    it 'returns false for other objects' do
      refute list.include?(:no_item)
    end
  end

  describe '#each_item' do
    before { list << item_a << item_b }

    it 'returns a sized enumerator' do
      enum = list.each_item
      
      assert_kind_of Enumerator, enum
      assert_equal list.count, enum.size
    end

    it 'iterates over each item' do
      res = []
      list.each_item { |item| res << item }

      assert_same item_a, res.first
      assert_same item_b, res.last
    end

    it 'is aliased to #each' do
      assert_equal list.method(:each_item), list.method(:each)
    end
  end

  describe '#reverse_each_item' do
    before { list << item_a << item_b }

    it 'returns a sized enumerator' do
      enum = list.reverse_each_item
      assert_kind_of Enumerator, enum
      assert_kind_of Numeric, enum.size
    end

    it 'iterates over each item in reverse' do
      res = []
      list.reverse_each_item { |item| res << item }

      assert_same item_b, res.first
      assert_same item_a, res.last
    end

    it 'is aliased to #reverse_each' do
      assert_equal list.method(:reverse_each_item), list.method(:reverse_each)
    end
  end

  describe '#dup' do
    before do
      item_a.value = 'a'
      list << item_a << item_b
    end

    it 'copies the entire chain of items' do
      duped_list = list.dup

      refute_same item_a, duped_list.first
      refute_same item_b, duped_list.last

      assert_equal item_a.value, duped_list.first.value
      refute_same item_a.value, duped_list.first.value
    end
  end

  describe '#freeze' do
    it 'freezes all list items' do
      list.push item_a
      list.push item_b

      list.freeze

      assert item_a.frozen?
      assert item_b.frozen?
    end

    it 'makes the list immutable' do
      list.push item_a
      list.freeze
      assert_raises(RuntimeError) { list.push item_b }
      assert_raises(RuntimeError) { item_a.append item_b }
    end
  end

  describe '#inspect' do
    before do
      item_a.value = 'a'
      item_b.value = 'b'

      list.push item_a
      list.push item_b
    end

    it 'contains the output of the items' do
      res = list.inspect

      refute_nil res[item_a.inspect]
      refute_nil res[item_b.inspect]
    end

    it 'accepts a block' do
      res = list.inspect { |item| item.value }

      refute_nil res["├─╴a\n"]
      refute_nil res['└─╴b']
    end
  end
end
