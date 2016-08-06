module Linked
  class List
    attr_reader :eol, :count
    
    def initialize(*)
      super
      
      @eol = EOL.new list: self
      @count = 0
    end
    
    alias head eol
    alias tail eol
    
    def first
      eol.next!
    end
    
    def last
      eol.prev!
    end
    
    protected def increment(n)
      @count += n
    end
    
    protected def decrement
      @count -= 1
    end
    
    # Returns true if the list does not contain any items.
    
    def empty?
      @count == 0
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
