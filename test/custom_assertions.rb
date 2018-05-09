# frozen_string_literal: true

require 'minitest/assertions'

module Minitest
  module Assertions
    # Fails unless the given items are all connected, in order, and are
    # complete. For the chain to be complete it must start with the first item,
    # end in the last and contain the correct count.
    def assert_chain(*items)
      head = items[0]
      tail = items[-1]

      assert_chain_head head
      assert_chain_tail tail

      assert_chain_length items.count, head

      items.each_cons(2) do |a, b|
        assert_chain_connection a, b
        assert_chain_first head, b
      end

      assert_chain_last tail, head
    end

    def assert_chain_head(item)
      assert item.first?, 'The item is not first in the chain'
    end

    def assert_chain_tail(item)
      assert item.last?, 'The item is not last in the chain'
    end

    def assert_chain_first(head, item)
      assert_same head, item.first_in_chain, '#first does not return the ' \
                                             'first item'
    end

    def assert_chain_last(tail, item)
      assert_same tail, item.last_in_chain, '#last does not return the last ' \
                                            'item'
    end

    def assert_chain_length(length, item)
      assert_equal length, item.chain_length, 'The chain count is not correct'
    end

    def assert_chain_connection(prev_item, next_item)
      assert_same next_item, prev_item.next, '#next returns the wrong item'
      assert_same prev_item, next_item.prev, '#prev returns the wrong item'
    end

    def assert_list_contains(list, *items)
      assert_equal items.length, list.count, 'The list count does not match'

      list.each.with_index do |item, index|
        assert_same items[index], item
      end
    end
  end
end
