module Linked
  class Item
    attr_accessor :list
    attr_writer :prev, :next
    protected :prev=, :next=, :list=
    
    # Creates a new item. If a list is given the item will be considered a part
    # of that list.
    #
    # list - An object responding to #head and #tail.
    #
    # Returns a new Item.
    
    def initialize(list = nil)
      @list = list
      if list
        @prev = list.head
        @next = list.tail
      else
        @next = nil
        @prev = nil
      end
    end
    
    # Check if this is the first item in the list.
    #
    # Returns true if no item come before this one.
    
    def first?
      @prev.nil?
    end
    
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
    
    # Inserts the given item between this one and the one after it (if any). If
    # this is the last item, and the items are part of a list, #prev= will be
    # called on the list tail.
    #
    # sibling - the item to append.
    
    def append(sibling)
      sibling.list = @list
      
      sibling.next = @next
      @next.prev = sibling if @next
      
      self.next = sibling
      sibling.prev = self
    end
    
    # Inserts the given item between this one and the one before it (if any). If
    # this is the first item, and the items are part of a list, #next= will be
    # called on the list head.
    #
    # sibling - the item to prepend.
    
    def prepend(sibling)
      sibling.list = @list
      
      sibling.prev = @prev
      @prev.next = sibling if @prev
      
      @prev = sibling
      sibling.next = self
    end
    
    # Remove an item from the chain. If this item is part of a list and is
    # either first, last or both in that list, #next= and #prev= will be called
    # on the list head and tail respectivly.
    #
    # Returns self.
    
    def delete
      @next.prev = @prev if @next
      @prev.next = @next if @prev
      
      @next = @prev = @list = nil
      self
    end
    
  end
end
