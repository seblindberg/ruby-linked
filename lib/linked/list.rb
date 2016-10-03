# frozen_string_literal: true

module Linked
  # List
  #
  # This class provides a way extend the regular chain of listable items with
  # the concept of an empty chain.
  #
  # Lists are ment to behave more like arrays, and respond to many of the same
  # methods.

  class List
    include Enumerable

    # Initializes the list.

    def initialize
      reset
      super
    end

    # When copying a list its entire item chain needs to be copied as well.
    # Therefore #dup will be called on each of the original lists items, making
    # this operation quite expensive.

    def initialize_dup(source)
      reset
      source.each_item { |item| push item.dup  }

      super
    end

    # Access the first item in the list. If the list is empty a NoMethodError
    # will be raised. This mirrors the behaviour of Item#item and allows other
    # methods that work on List objects to easily and interchangeably accept
    # both lists and items as arguments.
    #
    # Returns the first item in the list.

    def item
      raise NoMethodError if empty?
      @_chain
    end

    # Two lists are considered equal if the n:th item from each list are equal.
    #
    # other - any object.
    #
    # Returns true if the given object is a list and the items are equal.

    def ==(other)
      return false unless other.is_a? self.class
      return false unless other.count == self.count

      other_items = other.each_item
      each_item.all? { |item| item == other_items.next }
    end

    alias eql? ==

    # Access the first n item(s) in the list.
    #
    # n - the number of items to return.
    #
    # Returns, for different values of n:
    # n = nil) an item if the list contains one, or nil.
    #  n >= 0) an array of between 0 and n items, depending on how many are in.
    #          the list.

    def first(n = nil)
      return list_head unless n
      raise ArgumentError, 'n cannot be negative' if n < 0
      
      return [] if n == 0 || empty?

      list_head.take n
    end

    # Access the first n item(s) in the list.
    #
    # n - the number of items to return.
    #
    # Returns, for different values of n:
    # n = nil) an item if the list contains one, or nil.
    #  n >= 0) an array of between 0 and n items, depending on how many are in.
    #          the list. The order is preserved.

    def last(n = nil)
      return empty? ? nil : list_tail unless n
      raise ArgumentError, 'n cannot be negative' if n < 0
      
      return [] if n == 0 || empty?
      
      list_tail.take(-n)
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
        empty? ? 0 : @_chain.chain_length
      else
        super
      end
    end

    # Returns true if the list does not contain any items.

    def empty?
      @_chain == nil
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
      item = coerce_item object
      
      if empty?
        @_chain = item
      else
        @_chain.chain_tail.append item
      end
            
      self
    end

    alias << push

    # Pop the last item off the list.
    #
    # Returns the last item in the list, or nil if the list is empty.

    def pop
      return nil if empty?
      if last.first?
        item = last
        @_chain = nil
        item
      else
        last.delete
      end
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
      item = coerce_item object
      
      if empty?
        @_chain = item.chain_head
      else
        @_chain = @_chain.prepend item
      end
            
      self
    end

    # Shift the first item off the list.
    #
    # Returns the first item in the list, or nil if the list is empty.

    def shift
      return nil if empty?
      if list_head.last?
        item = @_chain
        @_chain = nil
        item
      else
        old_head = list_head
        @_chain = list_head.next
        old_head.delete
      end
    end

    # Check if an item is in the list.
    #
    # item - Item, or any object that may be in the list.
    #
    # Returns true if the given item is in the list, otherwise false.

    def include?(item)
      return false if empty?
      @_chain.in_chain? item
    end

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

    # Calls #freeze on all items in the list, as well as the head and the tail
    # (eol).

    def freeze
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
    # This method can be overridden to support different Item types.
    #
    # args - any arguments will be passed on to Item.new.
    #
    # Returns a new Item.

    protected def create_item(*args)
      Item.new(*args)
    end
    
    private def coerce_item(object)
      if object.respond_to? :item
        object.item
      else
        create_item object
      end
    end
    
    protected def reset
      @_chain = nil
    end

    # Returns the first item item in the list, or nil if empty.

    protected def list_head
      @_chain
    end

    # Returns an the last item in the list, or nil if empty.

    protected def list_tail
      @_chain.chain_tail
    end
  end
end
