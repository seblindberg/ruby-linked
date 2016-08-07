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

    # Access the first n item(s) in the list.
    #
    # n - the number of items to return.
    #
    # Returns the first item, or an array of items if n > 1.

    def first(*args)
      if args.empty?
        eol.next!
      else
        super
      end
    end

    # Access the last n item(s) in the list. When n > 1 the resulting array of
    # items will have their order preserved.
    #
    # When n is zero an empty array will be returned, in order to comply with
    # the behaviour of #first. Negative values will raise an ArgumentError.
    #
    # n - the number of items to return.
    #
    # Returns the last item, or an array of items if n > 1.

    def last(n = 1)
      if n == 1
        eol.prev!
      else
        raise ArgumentError, 'n cannot be negative' if n < 0

        n = count if n > count
        res = Array.new n

        return res if n == 0

        item = eol.prev!
        loop do
          n -= 1
          res[n] = item
          item = item.prev
        end

        res
      end
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
    # reverse - flips the iteration order if true.

    def each_item(reverse: false, &block)
      if reverse
        eol.before(&block)
      else
        eol.after(&block)
      end
    end
    
    alias each each_item
    
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
  end
end
