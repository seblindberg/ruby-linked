# frozen_string_literal: true

module Linked
  # List
  #
  # This module can be included in any class to give it list like behaviour.
  # Most importantly, the methods #head, #tail, #grow and #shrink are
  # implemented to comply with the requirements defined by Item.
  #
  # Example
  #
  #   class ListLike
  #     include Linked::List
  #
  #     def initialize
  #       super
  #       ...
  #
  # A key implementation detail is the End-Of-List, or EOL object that sits
  # between the list and the actual list items. It provides separation between
  # the list and the actual list items.

  module List
    include Enumerable

    # Private accessor method for the End-Of-List object.
    #
    # Returns a List::EOL object.

    attr_reader :eol
    private :eol

    # Returns an object that responds to #next= and #prepend.

    alias head eol

    # Returns an object that responds to #prev= and #append.

    alias tail eol

    # Initializes the list by setting the two instance variable @item_count and
    # @eol. It is important that this method be called during the initialization
    # of the including class, and that the instance variables never be accessed
    # directly.

    def initialize(*)
      @eol = EOL.new list: self
      @item_count = 0
      
      super
    end
    
    # When copying a list its entire item chain needs to be copied as well.
    # Therefore #dup will be called on each of the original lists items, making
    # this operation quite expensive.
    
    def initialize_dup(source)
      @eol = EOL.new list: self
      @item_count = 0
      
      source.each_item { |item| push item.dup  }
      
      super
    end

    # Access the first n item(s) in the list. If a block is given each item will
    # be yielded to it. The first item, starting from the first in the list, for
    # which the block returns true and the n - 1 items directly following it
    # will be returned.
    #
    # n - the number of items to return.
    #
    # Returns, for different values of n:
    # n == 0) nil
    # n == 1) an item if the list contains one, or nil
    #  n > 1) an array of between 0 and n items, depending on how many are in
    #         the list

    def first(n = 1)
      raise ArgumentError, 'n cannot be negative' if n < 0
      
      return first_item_after eol, count, n unless block_given?
      
      item = eol
      items_left = count
      
      items_left.times do
        break if yield next_item = item.next
        item = next_item
        items_left -= 1
      end
      
      first_item_after item, items_left, n
    end

    # Access the last n item(s) in the list. The items will retain thier order.
    # If a block is given each item, starting with the last in the list, will be
    # yielded to it. The first item for which the block returns true and the
    # n - 1 items directly preceding it will be returned.
    #
    # n - the number of items to return.
    #
    # Returns, for different values of n:
    # n == 0) nil
    # n == 1) an item if the list contains one, or nil
    #  n > 1) an array of between 0 and n items, depending on how many are in
    #         the list

    def last(n = 1)
      raise ArgumentError, 'n cannot be negative' if n < 0
      
      return last_item_before eol, count, n unless block_given?
      
      item = eol
      items_left = count
      
      items_left.times do
        break if yield prev_item = item.prev
        item = prev_item
        items_left -= 1
      end

      last_item_before item, items_left, n
    end

    # Overrides the Enumerable#count method when given no argument to provide a
    # fast item count. Instead of iterating over each item, the internal item
    # count is returned.
    #
    # args - see Enumerable#count
    #
    # Returns the number of items counted.

    def count(*args)
      if args.empty? && !block_given?
        @item_count
      else
        super
      end
    end

    # Returns true if the list does not contain any items.

    def empty?
      @item_count == 0
    end

    # Insert an item at the end of the list. If the given object is not an Item,
    # or a decendant of Item, it will be treated as a value. Depending on the
    # state of the list the value will be
    # a) wraped in a new instance of Item if the list is empty or
    # b) wraped in an object of the same class as the last item in the list.
    #
    # item - the item to insert, or an arbitrary value.
    #
    # Returns self.

    def push(item)
      eol.append item
      self
    end

    alias << push

    # Pop the last item off the list.
    #
    # Returns the last item in the list, or nil if the list is empty.

    def pop
      return nil if empty?
      last.delete
    end

    # Insert an item at the beginning of the list. If the given object is not an
    # Item, or a decendant of Item, it will be treated as a value. Depending on
    # the state of the list the value will be
    # a) wraped in a new instance of Item if the list is empty or
    # b) wraped in an object of the same class as the last item in the list.
    #
    # item - the item to insert, or an arbitrary value.
    #
    # Returns self.

    def unshift(item)
      eol.prepend item
      self
    end

    # Shift the first item off the list.
    #
    # Returns the first item in the list, or nil if the list is empty.

    def shift
      return nil if empty?
      first.delete
    end

    # Iterates over each item in the list, either in normal or reverse order. If
    # a block is not given an enumerator is returned.
    #
    # reverse - flips the iteration order if true. Note that this option is
    #           depricated and will be removed in the next major release.

    def each_item(reverse: false, &block)
      if reverse
        warn '[DEPRECATION] the option `reverse: true` will be removed in a future release. Please call `reverse_each_item` instead.'
        eol.before(&block)
      else
        eol.after(&block)
      end
    end
    
    alias each each_item
    
    # Iterates over each item in the list in reverse order. If a block is not
    # given an enumerator is returned.
    
    def reverse_each_item(&block)
      eol.before(&block)
    end
    
    alias reverse_each reverse_each_item
    
    # Calls #freeze on all items in the list, as well as the head and the tail
    # (eol).
    
    def freeze
      eol.freeze
      each_item(&:freeze)
      super
    end

    # Overrides the default inspect method to provide a more useful view of the
    # list.
    #
    # Importantly this implementation supports nested lists and will return a
    # tree like structure.

    def inspect(&block)
      # Get the parents inspect output
      res = [super]
      
      each_item do |item|
        lines = item.inspect(&block).split "\n"
        
        res.push (item.last? ? '└─╴' : '├─╴') + lines.shift
        padding = item.last? ? '   ' : '│  '
        lines.each { |line| res.push padding + line }
      end
      
      res.join("\n")
    end

    # Internal method to grow the list with n elements. Never call this method
    # without also inserting the n elements.
    #
    # n - the number of items that has been/will be added to the list.
    #
    # Returns updated the item count.

    private def grow(n = 1)
      @item_count += n
    end

    # Internal method to shrink the list with n elements. Never call this method
    # without also deleting the n elements.
    #
    # n - the number of items that has been/will be removed from the list.
    #
    # Returns updated the item count.

    private def shrink(n = 1)
      @item_count -= n
    end
    
    # Private helper method that returns the first n items, starting just after
    # item,  given that there are items_left items left. The following must hold
    # for the output to be valid:
    # a) n > 0
    # b) there are at least items_left items left
    #
    # item - the Item just before the item to start from
    # items_left - the number of items left.
    # n - the number of items to return.
    #
    # Returns, for different values of n:
    # n == 0) nil
    # n == 1) an item if items_left > 0 or nil
    #  n > 1) an array of items if items_left > 0 or an empty array
    
    private def first_item_after(item, items_left, n)
      # Optimize for these cases
      return nil if n == 0
      return item.next if n == 1
      
      (n > items_left ? items_left : n).times.map { item = item.next }
    rescue StopIteration
      n > 1 ? [] : nil
    end
    
    # Private helper method that returns the last n items, ending just before
    # item,  given that there are items_left items left. The following must hold
    # for the output to be valid:
    # a) n > 0
    # b) there are at least items_left items left
    #
    # item - the Item just after the item to start from.
    # items_left - the number of items left.
    # n - the number of items to return.
    #
    # Returns, for different values of n:
    # n == 0) nil
    # n == 1) an item if items_left > 0 or nil
    #  n > 1) an array of items if items_left > 0 or an empty array
    
    private def last_item_before(item, items_left, n)
      # Optimize for these cases
      return nil if n == 0
      return item.prev if n == 1
      
      # Truncate n if it is larger than the number of items
      # left
      n = (n > items_left ? items_left : n)
      (n - 1).downto(0).with_object(Array.new n) do |i, arr|
        arr[i] = item = item.prev
      end
    rescue StopIteration
      n > 1 ? [] : nil
    end
  end
end
