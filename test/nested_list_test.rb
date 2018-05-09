# frozen_string_literal: true

require 'test_helper'

# Creates a list that is itself listable

class NestedListItem < Linked::List
  include Linked::Listable

  attr_accessor :value

  def initialize(value = nil)
    super()
    @value = value
  end

  def inspect
    inspect_list { value.to_s }
  end
end

describe 'Nesting Lists' do
  subject { ::NestedListItem }

  let(:item) { subject.new :item }
  let(:sibling_a) { subject.new :sa }
  let(:sibling_b) { subject.new :sb }
  let(:child_a) { subject.new :ca }
  let(:child_b) { subject.new :cb }

  describe '#item' do
    it 'returns itself' do
      assert_same item, item.item
    end
  end

  it 'accepts siblings' do
    item.prepend sibling_a
    item.append sibling_b

    assert_same sibling_a, item.prev
    assert_same sibling_b, item.next
  end

  it 'accepts arbitrary objects as siblings' do
    item.prepend :a
    item.append :b

    assert_equal :a, item.prev.value
    assert_kind_of subject, item.next
  end

  it 'accepts children' do
    item.unshift child_a
    item.push child_b

    assert_same child_a, item.first
    assert_same child_b, item.last
  end

  it 'accepts arbitrary objects as children' do
    item.unshift :a
    item.push :b

    assert_same :a, item.first.value
    assert_kind_of subject, item.last
  end

  it 'duplicates the children' do
    item.prepend sibling_a # sA <> I
    item.append sibling_b  # sA <> I <> sB
    item.unshift child_a   #   cA -+
    item.push child_b      #   cA -+- cB

    duped_item = item.dup

    assert duped_item.first? && duped_item.last?
    assert_same item, sibling_a.next

    assert_equal 2, duped_item.count
    refute_same child_a, duped_item.first
    assert_equal :ca, duped_item.first.value
  end

  it 'duplicates a child' do
    item.append sibling_a
    item << child_a
    child_a << child_b

    duped_child_a = child_a.dup

    refute item.include? duped_child_a

    assert_equal 1, duped_child_a.count
    assert_kind_of subject, duped_child_a.first
    refute_same child_b, duped_child_a.first
  end

  it 'inspects the entire subtree' do
    item << sibling_a << sibling_b
    sibling_a << child_a
    sibling_b << child_b
    res = item.inspect

    assert_match(/\Aitem/, res)
    assert_match(/├─╴sa/, res)
    assert_match(/   └─╴cb\z/, res)
  end
end
