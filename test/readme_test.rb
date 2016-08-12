require 'test_helper'

describe 'README.md' do
  describe 'usage' do
    it 'works as promised' do
      # Create a list
      list = Linked::List.new

      # Append values
      list << :value
      list << 'value'

      # Or create list items manually
      item = Linked::Item.new 42
      list.unshift item

      # Remove items with #pop and #shift
      res = list.pop.value # => 'value'
      assert_equal 'value', res

      # The list behaves much like an Array
      res = list.count # => 2
      assert_equal 2, res

      res = list.map(&:value) # => [42, :value]
      assert_equal [42, :value], res
    end
  end
end
