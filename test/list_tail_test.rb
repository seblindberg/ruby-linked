require 'test_helper'

describe Linked::List::Tail do
  subject { Linked::List::Tail }
  let(:tail) { subject.new }
  let(:item) { Minitest::Mock.new }

  describe '#nil?' do
    it 'returns true' do
      assert tail.nil?
    end
  end

  describe '#prev' do
    it 'raises a StopIteration if no previous item has been set' do
      assert_raises(StopIteration) { tail.prev }
    end

    it 'allows next to be set' do
      item.expect :nil?, false
      tail.prev = item
      assert_equal item.object_id, tail.prev.object_id
    end
    
    it 'is aliased to #previous and #previous=' do
      assert_equal tail.method(:prev), tail.method(:previous)
      assert_equal tail.method(:prev=), tail.method(:previous=)
    end
  end
end
