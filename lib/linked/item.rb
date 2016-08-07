# Item
#
# This class implements doubly linked list items, designed to work both on their
# own and as children of list.
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
# a) responds to #next= and #prev= respectivly and
# b) returns true for #nil?.

module Linked
  class Item
    attr_accessor :list, :value
    attr_writer :prev, :next
    protected :prev=, :next=, :list=
    
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
    
    def append(sibling)
      if sibling.is_a? Item
        sibling.split
      else
        sibling = self.class.new sibling
      end
      
      sibling.prev = self
      after_sibling = @next
      @next = sibling
      
      count = 1 + loop.count do
        sibling.list = @list
        sibling = sibling.next
      end
      
      @list.send :grow, count if @list
      
      sibling.next = after_sibling
      after_sibling.prev = sibling if after_sibling
      sibling
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
    
    def prepend(sibling)
      if sibling.is_a? Item
        sibling.split after: true
      else
        sibling = self.class.new sibling
      end
      
      sibling.next = self
      before_sibling = @prev
      @prev = sibling
      
      count = 1 + loop.count do
        sibling.list = @list
        sibling = sibling.prev
      end
      
      @list.send :grow, count if @list
      
      sibling.prev = before_sibling
      before_sibling.next = sibling if before_sibling
      sibling
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
  end
end
