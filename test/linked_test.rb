require 'test_helper'

describe Linked do
  it 'has a version number' do
    refute_nil ::Linked::VERSION
  end
  
  describe '#List' do
    it 'returns the list back when given one'
    it 'inserts one or more Items into a new list'
    it 'converts an array to a List'
    it 'wraps an arbitrary object in a single Item in a new List'
  end
end
