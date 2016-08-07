require 'test_helper'

class NestedListItem < Linked::Item
  include Linked::List
end

describe 'Nesting Lists' do
  subject { ::NestedListItem }
  let(:item) { subject.new }
  let(:sibling_a) { subject.new }
  let(:sibling_b) { subject.new }
  let(:child_a) { subject.new :a }
  let(:child_b) { subject.new :b }
  
  it 'accepts siblings' do
    item.prepend sibling_a
    item.append sibling_b
    
    assert_same sibling_a, item.prev
    assert_same sibling_b, item.next
  end
  
  it 'accepts children' do
    item.unshift child_a
    item.push child_b

    assert_same child_a, item.first
    assert_same child_b, item.last
  end
  
  it 'duplicates the children' do
    item.prepend sibling_a
    item.append sibling_b
    item.unshift child_a
    item.push child_b
    
    duped_item = item.dup
    
    assert duped_item.first? && duped_item.last?
    assert_same item, sibling_a.next
    
    refute_same child_a, duped_item.first
    assert_equal :a, duped_item.first.value
  end
end
