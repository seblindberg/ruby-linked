# frozen_string_literal: true

# TODO: Think about moving some of basic functionallity of Item into Listable.

module Linked
  # Item
  #
  # This class implements doubly linked list items, designed to work both on
  # their own and as children of list.
  #
  #             +- - - +    +------+------+            +- - - +
  #             | Head | <--| prev | next |--> ... --> | Tail |
  #             + - - -+    +------+------+            + - - -+
  #            (optional)     First Item     N Items  (optional)
  #
  # An object is considered a list if it responds to #head, #tail, #grow and
  # #shrink. The latter facilitate counting of the items and will be called
  # everytime an item is appended, prepended or deleted. #head and #tail are
  # expected to return two objects that, respectivly
  # a) responds to #next= and #append, or #prev= and #prepend and
  # b) returns true for #nil?.
  #
  # Notation
  # --------
  #
  # Some methods operate on chains of items, and to describe the effects of an
  # operation the following syntax is used.
  #
  #                    A   ( A <> B )   [ A <> B ]
  #                   (i)     (ii)        (iii)
  #
  # Single items are denoted with capital letters (i), while chains are written
  # as multiple connected items (ii). The parenthesis are optional. To show that
  # one or more nodes are wraped in a list, angle brackets are used (iii).

  class Item
    # Access the list (if any) that the item belongs to. Writing to this
    # attribute is protected and should be avoided.
    #
    # Returns the item's list, or nil

    attr_writer :list
    protected :list=

    # The Item can hold an arbitrary object as its value and it will stay with
    # the item.

    attr_accessor :value

    # Calling either #prev= or #next= directly is not recommended since it may
    # corrupt the chain.

    attr_writer :prev, :next
    protected :prev=, :next=

    # Creates a new item. If a list is given the item will be considered a part
    # of that list and appended to the end of it.
    #
    # value - an arbitrary object to store with the item.
    # list - an object responding to #head and #tail.
    #
    # Returns a new Item.

    def initialize(value = nil, list: nil)
      @value = value
      @list = list
      if list
        list.tail.append self
      else
        @next = nil
        @prev = nil
      end
    end

    # Calling #dup on an item returns a copy that is no longer connected to the
    # original item chain, or the list. The value will also be copied.
    #
    # Returns a new Item.

    def initialize_dup(source)
      @next = @prev = @list = nil
      @value = begin
                 source.value.dup
               rescue TypeError
                 source.value
               end
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

    # Access the list that the item is part of. If the item is not in a list a
    # NoMethodError will be raised. This mirrors the behaviour of List#list and
    # allows other methods that work on List objects to easily and
    # interchangeably accept both lists and items as arguments.
    #
    # Returns the list that the item is part of.

    def list
      raise NoMethodError unless @list
      @list
    end

    # Check it the item is part of a list.
    #
    # Returns true if the item is in a list.

    def in_list?
      @list ? true : false
    end

    # Check if this is the first item in the list. It is crucial that tail#nil?
    # returns true for the first item to be identified correctly.
    #
    # Returns true if no item come before this one.

    def first?
      @prev.nil?
    end

    # Check if this is the last item in the list. It is crucial that head#nil?
    # returns true for the last item to be identified correctly.
    #
    # Returns true if no item come after this one.

    def last?
      @next.nil?
    end

    # Check if the item is in the given list.
    #
    # list - any object.
    #
    # Returns true if the item is part of the given list.

    def in?(list)
      @list.equal? list
    end
    
    # Item equality is solely determined by tha value. If the other object
    # responds to #value, and its value is equal (#==) to this value, the
    # objects are considered equal.
    #
    # other - any object.
    #
    # Returns true if the objects are considered equal.
    
    def ==(other)
      return false unless other.respond_to? :value
      value == other.value
    end
    
    alias eql? ==
    
    # Uses the hash value of the item value.
    #
    # Returns a fixnum that can be used by Hash to identify the item.
    
    def hash
      value.hash
    end

    # Access the next item in the list. If this is the last one a StopIteration
    # will be raised, so that items may be iterated over safely in a loop.
    #
    # Example
    #   loop do
    #     item = item.next
    #   end
    #
    # Returns the item that come after this.

    def next
      raise StopIteration if last?
      @next
    end

    # Unsafe accessor of the next item in the list. It is preferable to use
    # #next.
    #
    # Returns the item that come after this, or nil if this is the last one.

    def next!
      @next
    end

    # Access the previous item in the list. If this is the first one a
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
      raise StopIteration if first?
      @prev
    end

    alias previous prev

    # Unsafe accessor of the previous item in the list. It is preferable to use
    # #prev.
    #
    # Returns the item that come before this, or nil if this is the first one.

    def prev!
      @prev
    end

    alias previous! prev!

    # Inserts the given item between this one and the one after it (if any). If
    # the given item is part of a chain, all items following it will be moved to
    # this one, and added to the list if one is set.
    #
    # Example for the chain (A <> C)
    #
    #   A.append B # => (A <> B <> C)
    #
    # Alternativly the argument can be an arbitrary object, in which case a new
    # item will be created around it.
    #
    # If this item is part of a list #grow will be called on it with the
    # number of added items as an argument. Should it also be the last item
    # #prev= will be called on the list tail.
    #
    # object - the item to append, or an arbitrary object to be wraped in a new
    #          item. If in a list it will be asked to create the new item via
    #          List#create_item.
    #
    # Returns the last item that was appended.

    def append(object)
      if object.respond_to? :item
        first_item = object.item
        last_item = first_item.send :extract_beginning_with, @list
      else
        if @list
          first_item = last_item = @list.send :create_item, object
          first_item.list = @list
          @list.send :grow
        else
          first_item = last_item = self.class.new object
        end
      end

      first_item.prev = self
      @next.prev = last_item if @next
      @next, last_item.next = first_item, @next

      last_item
    end

    # Inserts the given item between this one and the one before it (if any). If
    # the given item is part of a chain, all items preceeding it will be moved
    # to this one, and added to the list if one is set.
    #
    # Example for the chain (A <> C)
    #
    #   C.prepend B # => (A <> B <> C)
    #
    # Alternativly the argument can be an arbitrary object, in which case a new
    # item will be created around it.
    #
    # If this item is part of a list #grow will be called on it with the
    # number of added items as an argument. Should it also be the first item
    # #next= will be called on the list head.
    #
    # object - the item to prepend. or an arbitrary object to be wraped in a
    #          new item. If in a list it will be asked to create the new item
    #          via List#create_item.
    #
    # Returns the last item that was prepended.

    def prepend(object)
      if object.respond_to? :item
        last_item = object.item
        first_item = last_item.send :extract_ending_with, @list
      else
        if @list
          first_item = last_item = @list.send :create_item, object
          first_item.list = @list
          @list.send :grow
        else
          first_item = last_item = self.class.new object
        end
      end

      last_item.next = self
      @prev.next = first_item if @prev
      @prev, first_item.prev = last_item, @prev

      first_item
    end

    # Remove an item from the chain. If this item is part of a list and is
    # either first, last or both in that list, #next= and #prev= will be called
    # on the list head and tail respectivly.
    #
    # If this item is part of a list #shrink will be called on it.
    #
    # Returns self.

    def delete
      @next.prev = @prev if @next
      @prev.next = @next if @prev
      @list.send :shrink if @list

      @next = @prev = @list = nil
      self
    end

    # Remove all items before this one in the chain. If the items are part of a
    # list they will be removed from it.
    #
    # Returns the last item in the chain that was just deleted, or nil if this
    # is the first item.

    def delete_before
      @prev.send :extract_ending_with unless first?
    end

    # Remove all items after this one in the chain. If the items are part of a
    # list they will be removed from it.
    #
    # Returns the last item in the chain that was just deleted, or nil if this
    # is the first item.

    def delete_after
      @next.send :extract_beginning_with unless last?
    end

    # Iterates over each item before this, in reverse order. If a block is not
    # given an enumerator is returned.
    #
    # Note that raising a StopIteraion inside the block will cause the loop to
    # silently stop the iteration early.

    def before
      return to_enum(__callee__) unless block_given?
      return if first?

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
      return if last?

      item = self.next

      loop do
        yield item
        item = item.next
      end
    end

    # Freezes the value, as well as making the list item itself immutable.

    def freeze
      value.freeze
      super
    end

    # The default #inspect method becomes very cluttered the moment you start
    # liking objects together. This implementation fixes that and only shows the
    # class name, object id and value (if set).

    def inspect
      return yield self if block_given?

      output = format '%s:0x%0x', self.class.name, object_id
      value ? output + " value=#{value.inspect}" : output
    end

    # PRIVATE DANGEROUS METHOD. This method should never be called directly
    # since it may leave the extracted item chain in an invalid state.
    #
    # This method extracts the item, together with the chain following it, from
    # the list they are in (if any) and optionally facilitates moving them to a
    # new list.
    #
    # Given the two lists
    #                         [ A <> B <> C ]   [ D ]
    #                               (I)          (II)
    #
    # calling B.extract_beginning_with(II) will result in (B <> C) being removed
    # from (I), and (II) to be grown by two. (B <> C) will now reference (II)
    # but they will not yet be linked to any of the items in it. It is therefore
    # necessary to insert them directly after calling this method, or (II) will
    # be left in an invalid state.
    #
    # Returns the last item of the chain.

    private def extract_beginning_with(new_list = nil)
      old_list = @list
      # Count items and move them to the new list
      last_item = self
      count = 1 + loop.count do
        last_item.list = new_list
        last_item = last_item.next
      end

      # Make sure the old list is in a valid state
      if old_list
        if first?
          old_list.send :clear
        else
          old_list.send :shrink, count
          # Fix the links within in the list
          @prev.next = last_item.next!
          last_item.next!.prev = @prev
        end
      else
        # Disconnect the item directly after the chain
        @prev.next = nil unless first?
      end

      # Disconnect the chain from the list
      @prev = last_item.next = nil

      # Preemptivly tell the new list to grow
      new_list.send :grow, count if new_list

      last_item
    end

    # PRIVATE DANGEROUS METHOD. This method should never be called directly
    # since it may leave the extracted item chain in an invalid state.
    #
    # This method extracts the item, together with the chain preceding it, from
    # the list they are in (if any) and optionally facilitates moving them to a
    # new list. See #extract_beginning_with for a description of the side
    # effects from calling this method.
    #
    # Returns the first item in the chain.

    private def extract_ending_with(new_list = nil)
      old_list = @list
      # Count items and move them to the new list
      first_item = self
      count = 1 + loop.count do
        first_item.list = new_list
        first_item = first_item.prev
      end

      # Make sure the old list is in a valid state
      if old_list
        if last?
          old_list.send :clear
        else
          old_list.send :shrink, count
          # Fix the links within in the list
          @next.prev = first_item.prev!
          first_item.prev!.next = @next
        end
      else
        # Disconnect the item directly after the chain
        @next.prev = nil unless last?
      end

      # Disconnect the chain from the list
      first_item.prev = @next = nil

      # Preemptivly tell the new list to grow
      new_list.send :grow, count if new_list

      first_item
    end
  end
end
