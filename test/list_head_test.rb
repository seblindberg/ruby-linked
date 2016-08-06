require 'test_helper'

describe Linked::List::Head do
  subject { Linked::List::Head }
  let(:head) { subject.new }
  let(:item) { Minitest::Mock.new }
  
  describe '#nil?' do
    it 'returns true' do
      assert head.nil?
    end
  end
  
  describe '#next' do
    it 'raises a StopIteration if no next item has been set' do
      assert_raises(StopIteration) { head.next }
    end
    
    it 'allows next to be set' do
      item.expect :nil?, false
      head.next = item
      assert_equal item.object_id, head.next.object_id
    end
  end
end
