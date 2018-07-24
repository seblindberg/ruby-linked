# frozen_string_literal: true

module Linked
  # This module collects all the methods that mutate a listable item.
  module Mutable
    # rubocop:disable Metrics/MethodLength

    def append(object)
      # Assume the given object to be the head of its chain
      # B. If it is not, chain B will be split before the
      # object, and the sub chain in which the object now is
      # the head will be appended.
      sub_chain_b_head = coerce object

      # Grab the first item in this chain. We will need it
      # later.
      target_chain = chain_head

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

    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength

    def prepend(object)
      sub_chain_a_tail = coerce object

      if chain_head?
        sub_chain_a_tail.split_after_and_insert
        sub_chain_a_tail.append self

        return chain_head
      end

      target_chain = chain_head

      sub_chain_a_head = sub_chain_a_tail.split_after_and_insert target_chain

      prev!.next = sub_chain_a_head
      sub_chain_a_head.prev = prev!

      sub_chain_a_tail.next = self
      self.prev = sub_chain_a_tail

      sub_chain_a_head
    end

    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength

    # Remove an item from the chain. Note that calling #delete on the first item
    # in a chain causes all subsequent items to be moved to a new chain.
    #
    # === Usage
    # Example using the chain A <> B <> C
    #
    #   A.delete # => A | B <> C
    #   B.delete # => B | A <> C
    #   C.delete # => C | A <> B
    #
    # @return [self]
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

    # rubocop:enable Metrics/MethodLength

    # Remove all items before this one in the chain.
    #
    # @return [nil] if this is the first item.
    # @return [Listable] the first item in the chain that was just deleted.
    def delete_before
      prev!.split_after_and_insert unless chain_head?
    end

    # Remove all items after this one in the chain.
    #
    # @return [nil] if this is the lst item.
    # @return [Listable] the first item in the chain that was just deleted.
    def delete_after
      return nil if chain_tail?

      item = next!
      item.split_before_and_insert
      item
    end

    protected

    # Never call this method directly since it may corrupt the chain.
    #
    # Sets the value of the `next` field.
    def next=(other)
      @_next = other
    end

    # Never call this method directly since it may corrupt the chain.
    #
    # Sets the value of the `prev` field.
    def prev=(other)
      @_prev = other
    end

    # Never call this method directly since it may corrupt the chain.
    #
    # Sets the value of the `first` field.
    def chain_head=(other)
      @_chain_head = other
    end

    # Never call this method directly since it may corrupt the chain. Grow the
    # chain with n items.
    #
    # n - the number of items to increase the chain count with.
    #
    # Returns the updated chain count.
    def grow(n = 1)
      head = chain_head
      head.chain_head = head.chain_head! + n
    end

    # Never call this method directly since it may corrupt the chain. Shrink the
    # chain with n items.
    #
    # n - the number of items to decrease the chain count with.
    #
    # Returns the updated chain count.
    def shrink(n = 1)
      head = chain_head
      head.chain_head = head.chain_head! - n
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength

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
    def split_before_and_insert(head_b = self)
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

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength

    # TODO

    def split_after_and_insert(head_a = chain_head)
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

    # rubocop:enable Metrics/MethodLength
  end
end
