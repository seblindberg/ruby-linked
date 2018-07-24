# frozen_string_literal: true

module Linked
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
  # === Notation
  # Some methods operate on chains of items, and to describe the effects of an
  # operation the following syntax is used.
  #
  #                                A     A <> B
  #                               (i)     (ii)
  #
  # Single items are denoted with capital letters (i), while chains are written
  # as multiple connected items (ii).
  module Listable
    extend  Forwardable
    include Util
    include Mutable

    # Creates a new item. Always make a call to super whenever overriding this
    # method in an including class.
    def initialize(*)
      reset_item
      super
    end

    # Calling #dup on an item returns a copy that is no longer connected to the
    # original item chain, or the list. The value will also be copied.
    #
    # @return [Listable] a new Listable.
    def initialize_copy(*)
      reset_item
      super
    end

    # Identity method that simply return the item. This method mirrors List#item
    # and allows other methods that work on Item objects to easily and
    # interchangebly accept both lists and items as arguments.
    #
    # @return [Listable] the item itself.
    def item
      self
    end

    # @!method chain_head?
    #
    # Returns true if no item come before this one. Note that the implementation
    # of this method is protected and publicly accessible through its alias
    # #first?.
    #
    # @return [true] if the item is the head of the chain.
    # @return [false] otherwise.
    def_delegator :@_prev, :chain_tail?, :chain_head?

    alias first? chain_head?

    # @!method chain_tail?
    #
    # Returns true if no item come after this one. Note that the implementation
    # of this method is protected and publicly accessible through its alias
    # #last?.
    #
    # @return [true] if the item is the tail of the chain.
    # @return [false] otherwise.
    def_delegator :@_next, :nil?, :chain_tail?

    alias last? chain_tail?

    # Returns the first item in the chain. Note that the implementation of this
    # method is protected and publicly accessible through its aliases
    # #first_in_chain and #chain.
    #
    # @return [Listable] the first item in the chain.
    def chain_head
      chain_head? ? self : chain_head!
    end

    alias first_in_chain chain_head
    alias chain chain_head

    # Returns the last item in the chain. Note that the implementation of this
    # method is protected and publicly accessible through its aliases
    # #last_in_chain.
    #
    # @return [Listable] the last item in the chain.
    def chain_tail
      chain_tail? ? self : chain_head.prev!
    end

    alias last_in_chain chain_tail

    # Returns the number of items in the current chain.
    #
    # @return [Integer] the number of items in the chain.
    def_delegator :chain_head, :chain_head!, :chain_length

    # Check if this object is in a chain.
    #
    # @param  other [Object] the object to check.
    # @return [true] if this object is in the same chain as the given one.
    # @return [false] otherwise.
    def in_chain?(other)
      return false unless other.is_a? Listable
      chain_head.equal? other.chain_head
    end

    alias === in_chain?

    # Access the next item in the chain. If this is the last one a StopIteration
    # will be raised, so that items may be iterated over safely in a loop.
    #
    # === Usage
    #   loop do
    #     item = item.next
    #   end
    #
    # @raise  [StopIteration] if this item is the last in the chain.
    #
    # @return [Listable] the item that come after this.
    def next
      raise StopIteration if chain_tail?
      @_next
    end

    # Access the previous item in the chain. If this is the first one a
    # StopIteration will be raised, so that items may be iterated over safely in
    # a loop.
    #
    # === Usage
    #   loop do
    #     item = item.prev
    #   end
    #
    # @raise  [StopIteration] if this item is the first in the chain.
    #
    # @return [Listable] the item that come before this.
    def prev
      raise StopIteration if chain_head?
      @_prev
    end

    alias previous prev

    # Iterates over each item before this, in reverse order. If a block is not
    # given an enumerator is returned.
    #
    # Note that raising a StopIteraion inside the block will cause the loop to
    # silently stop the iteration early.
    def before
      return to_enum(__callee__) unless block_given?
      return if chain_head?

      item = prev

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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity

    # Take n items and put them into a sorted array. If n is positive the array
    # will include this item, as well the n - 1 items following it in the chain.
    # If n is negative the items will be taken from before this item instead.
    #
    # If there are less than n - 1 items before/after this the resulting array
    # will contain less than n items.
    #
    # @raise  [ArgumentError] if `n` is not an integer.
    #
    # @param  n [Integer] the number of items to take.
    # @return [Array<Listable>] an array containing the taken items.
    def take(n)
      raise ArgumentError, 'n must be an integer' unless n.is_a? Integer

      # Optimize for the most simple cases
      return [self] if n == 1 || n == -1
      return [] if n.zero?

      n_abs = n.abs

      res = Array.new n_abs

      if n.positive?
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

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity

    # Due to the nature of listable objects the default #inspect method is
    # problematic. This basic replacement includes only the class name and the
    # object id.
    #
    # @return [String] a string representation of the object.
    def inspect
      block_given? ? yield(self) : object_identifier
    end

    protected

    # Protected factory method for creating items compatible with this listable
    # item. This method is called whenever an arbitrary object is appended or
    # prepended onto this item and need to be wraped/converted.
    #
    # This method can be overridden to support different behaviours.
    #
    # args - any arguments will be passed on to .new.
    #
    # Must return a new Listable object.
    def create_item(*args)
      self.class.new(*args)
    end

    # Protected unsafe accessor of the next item in the chain. It is preferable
    # to use #next, possibly in conjunction with #last?.
    #
    # Returns the item that come after this, or nil if this is the last one.
    def next!
      @_next
    end

    # Protected, unsafe accessor of the previous item in the chain. It is
    # preferable to use #prev, possibly in conjunction with #first?.
    #
    # Returns the item that come before this, or the last item in the chain if
    # this is the first one.
    def prev!
      @_prev
    end

    # Protected, unsafe accessor of the first item in the chain. It is
    # preferable to use #first.
    #
    # Returns the first item in the chain, or the chain item count if this is
    # the first one.
    def chain_head!
      @_chain_head
    end

    private

    # Convert the given object to a listable item. If the object responds to
    # #item the result of that call is returned. Otherwise a new item is created
    # using #create_item.
    #
    # @param  other [Object] the object to coerce.
    # @return [Listable] a listable item.
    def coerce(other)
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
    # @return [self]
    def reset_item
      @_chain_head = 1
      @_next = nil
      @_prev = self
    end

    protected :chain_head?, :chain_tail?, :chain_head, :chain_tail
  end
end
