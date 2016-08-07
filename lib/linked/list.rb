module Linked
  module List
    include Enumerable
    
    attr_reader :eol
    private :eol
    
    # Initializes the list by setting the two instance variable @item_count and
    # @eol. It is important that this method be called during the initialization
    # of the including class, and that the instance variables never be accessed
    # directly.
    
    def initialize(*)
      super
      
      @eol = EOL.new list: self
      @item_count = 0
    end
    
    alias head eol
    alias tail eol
    
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
    
    protected def increment(n)
      @item_count += n
    end
    
    protected def decrement
      @item_count -= 1
    end
    
    # Returns true if the list does not contain any items.
    
    def empty?
      @item_count == 0
    end
    
    # Insert an item at the end of the list.
    #
    # item - the Item to insert.
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
    
    # Insert an item at the beginning of the list.
    #
    # item - the Item to insert.
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
    
    def each(reverse: false, &block)
      if reverse
        eol.before(&block)
      else
        eol.after(&block)
      end
    end
  end
end
