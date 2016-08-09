# frozen_string_literal: true

module Linked
  # Item
  #
  # This class implements doubly linked list items, designed to work both on
  # their own and as children of list.
  #
  #  +- - - +    +------+------+            +- - - +
  #  | Head | <--| prev | next |--> ... --> | Tail |
  #  + - - -+    +------+------+            + - - -+
  # (optional)     First Item     N Items  (optional)
  #
  # An object is considered a list if it responds to #head, #tail, #grow and
  # #shrink. The latter facilitate counting of the items and will be called
  # everytime an item is appended, prepended or deleted. #head and #tail are
  # expected to return two objects that, respectivly
  # a) responds to #next= and #append, or #prev= and #prepend and
  # b) returns true for #nil?.

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

    # Calling either #prev= or #next= directly is not recommended, since can
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

    # Split the chain of items in two. If the chain belongs to a list this item
    # and all that stay connected to it will continue to belong to it, while the
    # rest are removed from it.
    #
    # By default all items followng this one will be kept together, but if given
    # the argument after: true, the split will instead happen after this item
    # and it will instead be kept with those before it.
    #
    # Example
    #
    #   item_b.split(after: false) => ~item_a~ |> item_b     item_c
    #   item_b.split(after: true)  =>  item_a     item_b <| ~item_c~
    #
    # after - determine wheter to split the chain before or after this item.
    #
    # Returns self.

    def split after: false
      warn '[DEPRECATION] this method will be removed in the next major update. Please use #delete_before and #delete_after instead'
      if after
        unless last?
          if @list
            item = self
            count = 1 + loop.count do
              item = item.next
              item.list = nil
            end

            tail = @list.tail
            tail.prev = self
            @next = tail
            @list.shrink count
          else
            @next.prev = nil
            @next = nil
          end
        end
      else
        unless first?
          if @list
            item = self
            count = 1 + loop.count do
              item = item.prev
              item.list = nil
            end

            head = @list.head
            head.next = self
            @prev = head
            @list.shrink count
          else
            @prev.next = nil
            @prev = nil
          end
        end
      end

      self
    end

    # Inserts the given item between this one and the one after it (if any). If
    # the given item is part of a chain, all items following it will be moved to
    # this one, and added to the list if one is set.
    #
    # Alternativly the argument can be an arbitrary object, in which case a new
    # item will be created around it.
    #
    # If this item is part of a list #grow will be called on it with the
    # number of added items as an argument. Should it also be the last item
    # #prev= will be called on the list tail.
    #
    # sibling - the item to append, or an arbitrary object to be wraped in a new
    #           item.
    #
    # Returns the last item that was appended.

    def append(object)
      count = 1
      if object.respond_to? :item
        first_item = object.item.send :extract_from
        last_item = first_item
        
        loop do
          last_item.list = @list
          last_item = last_item.next
          count += 1 # Must happen before last_item.next
        end
      else
        first_item = last_item = self.class.new object
        first_item.list = @list
      end

      first_item.prev = self
      @next.prev = last_item if @next
      @next, last_item.next = first_item, @next
      
      @list.send :grow, count if @list
      last_item
    end

    # Inserts the given item between this one and the one before it (if any). If
    # the given item is part of a chain, all items preceeding it will be moved
    # to this one, and added to the list if one is set.
    #
    # Alternativly the argument can be an arbitrary object, in which case a new
    # item will be created around it.
    #
    # If this item is part of a list #grow will be called on it with the
    # number of added items as an argument. Should it also be the first item
    # #next= will be called on the list head.
    #
    # sibling - the item to prepend. or an arbitrary object to be wraped in a
    #           new item.
    #
    # Returns the last item that was prepended.

    def prepend(object)
      count = 1
      if object.respond_to? :item
        last_item = object.item.send :extract_upto
        first_item = last_item
        
        loop do
          first_item.list = @list
          first_item = first_item.prev
          count += 1 # Must happen before last_item.next
        end
      else
        first_item = last_item = self.class.new object
        first_item.list = @list
      end
      
      # Hook up the item(s)
      last_item.next = self
      @prev.next = first_item if @prev
      @prev, first_item.prev = last_item, @prev
      
      @list.send :grow, count if @list
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
      prev.extract_upto unless first?
    end
    
    def delete_after
      
    end

    # Iterates over each item before this, in reverse order. If a block is not
    # given an enumerator is returned.

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
    
    # PRIVATE DANGEROUS METHOD.
    #
    # This method should never be called directly since it leaves the extracted
    # item chain in an invalid state. The following needs to be done immediately
    # after this method returns:
    # a) The list, if any, must be cleared from all items.
    # b) @prev of the first item must be set.
    #
    # Returns self.
    
    private def extract_from
      if first?
        @list.send :clear if in_list?
        return self
      end
      
      unless in_list?
        @prev.next = nil
        return self
      end
      
      item = self
      count = 1 + loop.count { item = item.next }
      
      @prev.next = item.next!
      item.next!.prev = @prev
      item.next = nil
      
      @list.send :shrink, count
      self
    end
    
    # PRIVATE DANGEROUS METHOD.
    #
    # This method should never be called directly since it leaves the extracted
    # item chain in an invalid state. The following needs to be done immediately
    # after this method returns:
    # a) The list, if any, must be cleared from all items.
    # b) @next of the last item must be set.
    #
    # Returns self.
    
    private def extract_upto
      if last?
        @list.send :clear if in_list?
        return self
      end
      
      unless in_list?
        @next.prev = nil
        return self
      end
      
      item = self
      count = 1 + loop.count { item = item.prev }
      
      @next.prev = item.prev!
      item.prev!.next = @next
      item.prev = nil
      
      @list.send :shrink, count
      self
    end
  end
end
