require 'test_helper'

describe Linked::Item do
  subject { ::Linked::Item }

  let(:item) { subject.new }
  let(:item_a) { subject.new }
  let(:item_b) { subject.new }

  describe '.new' do
    it 'accepts a value' do
      item = subject.new :value
      assert_equal :value, item.value
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
  
  describe '#hash' do
    it 'returns the same hash for items with equal values' do
      item_a.value = :value
      item_b.value = :value
      
      assert_equal item_a.hash, item_b.hash
    end
    
    it 'returns different hashes for items with different values' do
      item_a.value = :a
      item_b.value = :b
      
      refute_equal item_a.hash, item_b.hash
    end
  end

  describe '#dup' do
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
  end
end
