# frozen_string_literal: true

module Linked
  # Expects the list to implement `#list_head` and `#list_tail`.
  module ListEnumerable
    include Enumerable

    # Iterates over each item in the list If a block is not given an enumerator
    # is returned.
    def each_item
      return to_enum(__method__) { count } unless block_given?
      return if empty?

      item = list_head
      loop do
        yield item
        item = item.next
      end
    end

    alias each each_item

    # Iterates over each item in the list in reverse order. If a block is not
    # given an enumerator is returned.
    #
    # @yield  [Listable] each item in the list.
    # @return [Enumerable] if no block is given.
    def reverse_each_item
      return to_enum(__method__) { count } unless block_given?
      return if empty?

      item = list_tail
      loop do
        yield item
        item = item.prev
      end
    end

    alias reverse_each reverse_each_item

    # Access the first n item(s) in the list.
    #
    # @param  n [Integer] the number of items to return.
    # @return [Listable] if n = nil.
    # @return [Array<Listable>] if n >= 0.
    def first(n = nil)
      return list_head unless n
      raise ArgumentError, 'n cannot be negative' if n.negative?

      return [] if n.zero? || empty?

      list_head.take n
    end

    # Access the first n item(s) in the list.
    #
    # @param  n [Integer] the number of items to return.
    # @return [Listable] if n = nil.
    # @return [Array<Listable>] if n >= 0. The order is preserved.
    def last(n = nil)
      return empty? ? nil : list_tail unless n
      raise ArgumentError, 'n cannot be negative' if n.negative?

      return [] if n.zero? || empty?

      list_tail.take(-n)
    end

    # Overrides the Enumerable#count method when given no argument to provide a
    # fast item count. Instead of iterating over each item, the internal item
    # count is returned.
    #
    # @param  args [Array<Object>] see Enumerable#count
    # @return [Integer] the number of items counted.
    def count(*args)
      if args.empty? && !block_given?
        empty? ? 0 : list_head.chain_length
      else
        super
      end
    end
  end
end
