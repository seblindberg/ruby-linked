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

    # Identity method that simply return the list. This method mirrors Item#list
    # and allows other methods that work on List objects to easily and
    # interchangebly accept both lists and items as arguments.
    #
    # Returns the list itself.

    def list
      self
    end

    # Access the first item in the list. If the list is empty a NoMethodError
    # will be raised. This mirrors the behaviour of Item#item and allows other
    # methods that work on List objects to easily and interchangeably accept
    # both lists and items as arguments.
    #
    # Returns the first item in the list.

    def item
      raise NoMethodError if empty?
      eol.next
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

      return first_item_after eol, n, count unless block_given?

      item = eol
      items_left = count

      items_left.times do
        break if yield next_item = item.next
        item = next_item
        items_left -= 1
      end

      first_item_after item, n, items_left
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

      return last_item_before eol, n, count unless block_given?

      item = eol
      items_left = count

      items_left.times do
        break if yield prev_item = item.prev
        item = prev_item
        items_left -= 1
      end

      last_item_before item, n, items_left
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

    # Insert an item at the end of the list. If the given object is not an
    # object responding to #item it will be treated as a value. The value will
    # be wraped in a new Item create by #create_item.
    #
    # See Item#append for more details.
    #
    # object - the item to insert, or an arbitrary object.
    #
    # Returns self.

    def push(object)
      eol.append object
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
    # object responding to #item it will be treated as a value. The value will
    # be wraped in a new Item create by #create_item.
    #
    # See Item#prepend for more details.
    #
    # object - the item to insert, or an arbitrary object.
    #
    # Returns self.

    def unshift(object)
      eol.prepend object
      self
    end

    # Shift the first item off the list.
    #
    # Returns the first item in the list, or nil if the list is empty.

    def shift
      return nil if empty?
      first.delete
    end

    # Check if an item is in the list.
    #
    # item - Item, or any object that may be in the list.
    #
    # Returns true if the given item is in the list, otherwise false.

    def include?(item)
      item.in? self
    rescue NoMethodError
      false
    end

    # Iterates over each item in the list If a block is not given an enumerator
    # is returned.

    def each_item(&block)
      eol.after(&block)
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

    # Protected factory method for creating items compatible with the list. This
    # method is called whenever an arbitrary object is pushed or unshifted onto
    # the list and need to be wraped inside an Item.
    #
    # This method can be overridden to suport different Item types.
    #
    # args - any arguments will be passed on to Item.new.
    #
    # Returns a new Item.

    protected def create_item(*args)
      Item.new(*args)
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

    # Private method to clear the list. Never call this method without also
    # modifying the items in the list, as this operation leavs them in an
    # inconsistant state. If the list items are kept, make sure to
    # a) clear the `prev` pointer of the first item and
    # b) clear the `next` pointer of the last item.

    private def clear
      head.send :next=, tail
      tail.send :prev=, head

      @item_count = 0
    end

    # Protected helper method that returns the first n items, starting just
    # after item, given that there are items_left items left. Knowing the exact
    # number of items left is not cruicial but does impact speed. The number
    # should not be lower than the actual ammount. The following must
    # hold for the output to be valid:
    # a) n > 0
    # b) there are at least items_left items left
    #
    # item - the Item just before the item to start from.
    # n - the number of items to return.
    # items_left - the number of items left.
    #
    # Returns, for different values of n:
    # n == 0) nil
    # n == 1) an item if items_left > 0 or nil
    #  n > 1) an array of items if items_left > 0 or an empty array

    protected def first_item_after(item, n, items_left = @item_count)
      # Optimize for these cases
      return nil if n == 0
      return n > 1 ? [] : nil if item.next!.nil?
      return item.next if n == 1

      n = items_left if n > items_left

      arr = Array.new n
      n.times { |i| arr[i] = item = item.next }
      arr
    rescue StopIteration
      arr.compact! || arr
    end

    # Protected helper method that returns the last n items, ending just before
    # item,  given that there are items_left items left. Knowing the exact
    # number of items left is not cruicial but does impact speed. The number
    # should not be lower than the actual ammount. The following must hold for
    # the output to be valid:
    # a) n > 0
    # b) there are at least items_left items left
    #
    # item - the Item just after the item to start from.
    # n - the number of items to return.
    # items_left - the number of items left.
    #
    # Returns, for different values of n:
    # n == 0) nil
    # n == 1) an item if items_left > 0 or nil
    #  n > 1) an array of items if items_left > 0 or an empty array

    protected def last_item_before(item, n, items_left = @item_count)
      # Optimize for these cases
      return nil if n == 0
      return n > 1 ? [] : nil if item.prev!.nil?
      return item.prev if n == 1

      n = items_left if n > items_left

      arr = Array.new n
      (n - 1).downto(0) { |i| arr[i] = item = item.prev }
      arr
    rescue StopIteration
      arr.compact! || arr
    end

    # This method is called whenever the module is included somewhere. In the
    # special case when List is included in an Item the #item method must be
    # changed to return self.

    def self.included(klass)
      klass.send(:define_method, :item) { self } if klass < Item
    end
  end
end
