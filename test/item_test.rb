require 'test_helper'

describe Linked::Item do
  subject { ::Linked::Item }
  
  let(:item) { subject.new }
  
  describe '#first?' do
    it 'returns true when there is no item before it' do
      assert item.first?
    end
    
    it 'returns false when there is an item before it'
  end
  
  describe '#last?' do
    it 'returns true when there is no item after it' do
      assert item.last?
    end
    
    it 'returns false when there is an item after it'
  end
  
  describe '#next' do
    it 'returns the next item'
    
    it 'raises an exception when there is no item after it' do
      assert_raises(StopIteration) { item.next }
    end
  end
  
  describe '#next!' do
    it 'returns the next item'

    it 'returns nil when there is no item after it' do
      assert_nil item.next!
    end
  end
  
  describe '#prev' do
    it 'returns the previous item'

    it 'raises an exception when there is no item before it' do
      assert_raises(StopIteration) { item.prev }
    end
    
    it 'is aliased to #previous' do
      assert_equal item.method(:prev), item.method(:previous)
    end
  end

  describe '#prev!' do
    it 'returns the next item'

    it 'returns nil when there is no item before it' do
      assert_nil item.prev!
    end
    
    it 'is aliased to #previous!' do
      assert_equal item.method(:prev!), item.method(:previous!)
    end
  end
end
