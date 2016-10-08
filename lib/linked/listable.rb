module Linked
  # Listable
  #
  # The listable item is the foundational element of the linked list. Each link
  # in the chain knows what comes both before and after, as well as which
  # elements are in the beginning and end of the chain. This information can be
  # used to iterate over the chained elements.
  #
  # Internally each listable item stores three pointers: one to the head of the
  # chain and two for the previous and next items respectivly. The head of the
  # chain uses the head pointer to store how many elements are currently in the
  # chain, for fast access. Furthermore it uses its pointer to the previous
  # element to keep track of the last element of the chain.
  #
  # In pracitce this means that some operations are fast, or computationally
  # cheap, while other are more expensive. The follwing actions are fast:
  #
  # 1) Accessing the previous and next item.
  # 2) Accessing the first and last element of the chain.
  # 3) Calculating the length of the chain.
  # 4) Appending items.
  # 5) Deleting any item but the first one.
  #
  # On the flip side, the following are the expensive operations:
  #
  # 1) Prepending items.
  # 2) Deleting the first item.
  # 3) Splitting the chain.
  #
  # Notation
  # --------
  # Some methods operate on chains of items, and to describe the effects of an
  # operation the following syntax is used.
  #
  #                                A     A <> B
  #                               (i)     (ii)
  #
  # Single items are denoted with capital letters (i), while chains are written
  # as multiple connected items (ii).

  module Listable
    # Creates a new item. Always make a call to super whenever overriding this
    # method in an including class.

    def initialize(*)
      reset_item
      super
    end

    # Calling #dup on an item returns a copy that is no longer connected to the
    # original item chain, or the list. The value will also be copied.
    #
    # Returns a new Item.

    def initialize_copy(*)
      reset_item
      super
    end

    # Identity method that simply return the item. This method mirrors List#item
    # and allows other methods that work on Item objects to easily and
    # interchangebly accept both lists and items as arguments.
    #
    # Returns the item itself.

    def item
      self
    end
    
    # Returns true if no item come before this one. Note that the implementation
    # of this method is protected and publicly accessible through its alias
    # #first?.
    
    def chain_head?
      #p @_chain_head.is_a? Numeric
      #@_chain_head.is_a? Numeric
      @_prev.chain_tail?
    end
    
    alias first? chain_head?
    protected :chain_head?

    # Returns true if no item come after this one. Note that the implementation
    # of this method is protected and publicly accessible through its alias
    # #last?.

    def chain_tail?
      @_next.nil?
    end
    
    alias last? chain_tail?
    protected :chain_tail?
    
    # Returns the first item in the chain. Note that the implementation of this
    # method is protected and publicly accessible through its aliases
    # #first_in_chain and #chain.
    
    def chain_head
      chain_head? ? self : chain_head!
    end
        
    alias first_in_chain chain_head
    alias chain chain_head
    
    protected :chain_head
    
    # Returns the last item in the chain. Note that the implementation of this
    # method is protected and publicly accessible through its aliases
    # #last_in_chain.
    
    def chain_tail
      chain_tail? ? self : chain_head.prev!
    end
    
    alias last_in_chain chain_tail
    protected :chain_tail
    
    # Returns the number of items in the current chain.
    
    def chain_length
      self.chain_head.chain_head!
    end
    
    # Check if this object is in a chain.
    #
    # other - any Listable object.
    #
    # Returns true if this object is in the same chain as the given one.
    
    def in_chain?(other)
      return false unless other.is_a? Listable
      chain_head.equal? other.chain_head
    end
    
    alias === in_chain?

    # Access the next item in the chain. If this is the last one a StopIteration
    # will be raised, so that items may be iterated over safely in a loop.
    #
    # Example
    #   loop do
    #     item = item.next
    #   end
    #
    # Returns the item that come after this.

    def next
      raise StopIteration if chain_tail?
      @_next
    end

    # Access the previous item in the chain. If this is the first one a
    # StopIteration will be raised, so that items may be iterated over safely in
    # a loop.
    #
    # Example
    #   loop do
    #     item = item.prev
    #   end
    #
    # Returns the item that come before this.

    def prev
      raise StopIteration if chain_head?
      @_prev
    end

    alias previous prev
    
    # TODO

    def append(object)
      # Assume the given object to be the head of its chain
      # B. If it is not, chain B will be split before the
      # object, and the sub chain in which the object now is
      # the head will be appended.
      sub_chain_b_head = coerce object
      
      # Grab the first item in this chain. We will need it
      # later.
      target_chain = self.chain_head
      
      # Split chain B before the given object and grab the
      # tail of that new sub chain.
      sub_chain_b_tail = sub_chain_b_head.split_before_and_insert target_chain
      
      # If we are the last item in our chain we need to
      # notify the head that there is a new tail.
      # Otherwise the next item in the list need to be
      # linked up correctly.
      if chain_tail?
        target_chain.prev = sub_chain_b_tail
      else
        sub_chain_b_tail.next = next!
        next!.prev = sub_chain_b_tail
      end
      
      # Connect sub chain B to this item
      sub_chain_b_head.prev = self
      self.next = sub_chain_b_head
      
      sub_chain_b_tail
    end

    # TODO

    def prepend(object)
      sub_chain_a_tail = coerce object
      
      if chain_head?
        sub_chain_a_tail.split_after_and_insert
        sub_chain_a_tail.append self
        
        return chain_head
      end
      
      target_chain = self.chain_head
      
      sub_chain_a_head = sub_chain_a_tail.split_after_and_insert target_chain
      
      prev!.next = sub_chain_a_head
      sub_chain_a_head.prev = prev!
      
      sub_chain_a_tail.next = self
      self.prev = sub_chain_a_tail
      
      sub_chain_a_head
    end

    # Remove an item from the chain. Note that calling #delete on the first item
    # in a chain causes all subsequent items to be moved to a new chain.
    #
    # Example using the chain A <> B <> C
    #
    #   A.delete # => A | B <> C
    #   B.delete # => B | A <> C
    #   C.delete # => C | A <> B
    #
    # Returns self.

    def delete
      if chain_head?
        split_after_and_insert
      else
        shrink
        
        if chain_tail?
          chain_head.prev = @_prev
        else
          @_next.prev = @_prev
        end
        
        @_prev.next = @_next
      end

      reset_item
    end

    # Remove all items before this one in the chain.
    #
    # Returns the first item in the chain that was just deleted, or nil if this
    # is the first item.

    def delete_before
      prev!.split_after_and_insert unless chain_head?
    end

    # Remove all items after this one in the chain.
    #
    # Returns the first item in the chain that was just deleted, or nil if this
    # is the last item.

    def delete_after
      return nil if chain_tail?
      
      item = next!
      item.split_before_and_insert
      item
    end

    # Iterates over each item before this, in reverse order. If a block is not
    # given an enumerator is returned.
    #
    # Note that raising a StopIteraion inside the block will cause the loop to
    # silently stop the iteration early.

    def before
      return to_enum(__callee__) unless block_given?
      return if chain_head?

      item = self.prev

      loop do
        yield item
        item = item.prev
      end
    end

    # Iterates over each item after this. If a block is not given an enumerator
    # is returned.
    #
    # Note that raising a StopIteraion inside the block will cause the loop to
    # silently stop the iteration early.

    def after
      return to_enum(__callee__) unless block_given?
      return if chain_tail?

      item = self.next

      loop do
        yield item
        item = item.next
      end
    end
    
    # Take n items and put them into a sorted array. If n is positive the array
    # will include this item, as well the n - 1 items following it in the chain.
    # If n is negative the items will be taken from before this item instead.
    #
    # If there are less than n - 1 items before/after this the resulting array
    # will contain less than n items.
    
    def take(n)
      # Optimize for the most simple cases
      return [self] if n == 1 || n == -1
      return [] if n == 0
      
      raise ArgumentError, 'n must be an integer' unless n.is_a? Integer
      
      n_abs = n < 0 ? -n : n

      res = Array.new n_abs
      
      if n > 0
        res[0] = self
        enum = after
        iter = 1.upto(n_abs - 1)
      else
        res[n_abs - 1] = self
        enum = before
        iter = (n_abs - 2).downto 0
      end
      
      iter.each { |i| res[i] = enum.next }
      res
    rescue StopIteration
      res.compact!
      res
    end
    
    # Due to the nature of listable objects the default #inspect method is
    # problematic. This basic replacement includes only the class name and the
    # object id.
    
    def inspect
      format '%s:0x%0x', self.class.name, object_id
    end

    # Protected factory method for creating items compatible with this listable
    # item. This method is called whenever an arbitrary object is appended or
    # prepended onto this item and need to be wraped/converted.
    #
    # This method can be overridden to support different behaviours.
    #
    # args - any arguments will be passed on to .new.
    #
    # Must return a new Listable object.

    protected def create_item(*args)
      self.class.new(*args)
    end

    # Protected unsafe accessor of the next item in the chain. It is preferable
    # to use #next, possibly in conjunction with #last?.
    #
    # Returns the item that come after this, or nil if this is the last one.

    protected def next!
      @_next
    end

    # Never call this method directly since it may corrupt the chain.
    #
    # Sets the value of the `next` field.

    protected def next=(other)
      @_next = other
    end

    # Protected, unsafe accessor of the previous item in the chain. It is
    # preferable to use #prev, possibly in conjunction with #first?.
    #
    # Returns the item that come before this, or the last item in the chain if
    # this is the first one.

    protected def prev!
      @_prev
    end

    # Never call this method directly since it may corrupt the chain.
    #
    # Sets the value of the `prev` field.

    protected def prev=(other)
      @_prev = other
    end
    
    # Protected, unsafe accessor of the first item in the chain. It is
    # preferable to use #first.
    #
    # Returns the first item in the chain, or the chain item count if this is
    # the first one.
    
    protected def chain_head!
      @_chain_head
    end
    
    # Never call this method directly since it may corrupt the chain.
    #
    # Sets the value of the `first` field.
    
    protected def chain_head=(other)
      @_chain_head = other
    end
    
    # Never call this method directly since it may corrupt the chain. Grow the
    # chain with n items.
    #
    # n - the number of items to increase the chain count with.
    #
    # Returns the updated chain count.
    
    protected def grow(n = 1)
      head = chain_head
      head.chain_head = head.chain_head! + n
    end
    
    # Never call this method directly since it may corrupt the chain. Shrink the
    # chain with n items.
    #
    # n - the number of items to decrease the chain count with.
    #
    # Returns the updated chain count.
    
    protected def shrink(n = 1)
      head = chain_head
      head.chain_head = head.chain_head! - n
    end

    # Split the chain on this item and insert the latter part into the chain
    # with head as its first item.
    #
    # Calling C.split_before_and_insert(.) yields the two chains (ii) and (iii)
    #
    #   A <> B <> C <> D    A <> B    C <> D
    #         (i)            (ii)     (iii)
    #
    # Chain (ii) is guaranteed to be complete. Chain (iii) will however be left
    # in an inclomplete state unless head_b == self (default). The first item in
    # (iii) must then be connected to the one preceeding it.
    #
    # head_b - the head of a new chain that (iii) will be added to.
    #
    # Returns the last element of (iii).
    
    protected def split_before_and_insert(head_b = self)
      # Get the current chain head. It will remain the head
      # of sub chain a (ii). If this item is the first then
      # chain a will be empty.
      chain_a_head = chain_head? ? nil : chain_head
      
      # The head of sub chain b (iii) is self.
      chain_b_head = self
      
      # Find the tail of sub chain b by iterating over each
      # item, starting with this one. Set the the new head
      # of these while counting them.
      chain_b_tail = self
      chain_b_length = 1
      
      loop do
        chain_b_tail.chain_head = head_b
        chain_b_tail = chain_b_tail.next
        chain_b_length += 1
      end
      
      # If sub chain a is not empty it needs to be updated.
      # Shrink its count by the number of items in sub
      # chain b and complete it by connecting the head to
      # the tail.
      if chain_a_head
        chain_a_head.shrink chain_b_length
        
        chain_a_tail = chain_b_head.prev
        chain_a_head.prev = chain_a_tail
        chain_a_tail.next = nil
      end
      
      # Tell the new chain to grow. If sub chain b is to be
      # the new head we can insert the count directly. We
      # also complete the chain by connecting the head to
      # the tail. The next field of the tail should already
      # be nil.
      if chain_b_head.equal? head_b
        chain_b_head.chain_head = chain_b_length
        chain_b_head.prev = chain_b_tail
      else
        head_b.grow chain_b_length
      end
      
      # Chain a is now either empty (nil) or completed.
      # Chain b however is only complete if the given head
      # is equal to self (default). If it is not chain b
      # will need a) the next field of the tail set to the
      # item after, unless nil, and b) the prev field of
      # head set to the item before.
      
      chain_b_tail
    end
    
    # TODO
    
    protected def split_after_and_insert(head_a = chain_head)
      # If this is not the last item in the chain, sub chain
      # b will contain items. Use #split_before_and_insert
      # to cut the chain after this one. This will complete
      # chain b and update the item count of chain a.
      next!.split_before_and_insert unless chain_tail?
      
      chain_a_head = chain_head
      
      # If the head of sub chain a is same as the target
      # chain head
      return chain_a_head if chain_a_head.equal? head_a
      
      chain_a_length = chain_length
      
      # Set the head field of all items, starting with the
      # tail (self), moving backwards.
      item = self
      
      # Loop until we hit the first item.
      loop do
        item.chain_head = head_a
        item = item.prev
      end
      
      # Tell the target chain to grow with the number of
      # items in sub chain a.
      head_a.grow chain_a_length
      
      # Sub chain b is now either empty or complete. Sub
      # chain a however is only complete if the target
      # head is the same as the head of chain a. Otherwise
      # the prev field of head and the next field of tail
      # both need to be set correctly.
      
      chain_a_head
    end
    
    # Convert the given object to a listable item. If the object responds to
    # #item the result of that call is returned. Otherwise a new item is created
    # using #create_item.
    #
    # other - any object.
    #
    # Returns a listable item.
    
    private def coerce(other)
      if other.respond_to? :item
        other.item
      else
        create_item other
      end
    end
    
    # Reset the fields of the item to their initial state. This leaves the item
    # in a consistent state as a single item chain.
    #
    # Only call this method on items that are disconnected from their siblings.
    # Otherwise the original chain (if any) will be left in an inconsistent
    # state.
    #
    # Returns self.
    
    private def reset_item
      @_chain_head = 1
      @_next = nil
      @_prev = self
    end
  end
end
