module Linked
  class Item
    def initialize
      @next = nil
      @prev = nil
    end
    
    def first?
      @prev.nil?
    end
    
    def last?
      @next.nil?
    end
    
    def next
      raise StopIteration if last?
      @next
    end
    
    def next!
      @next
    end
    
    def prev
      raise StopIteration if first?
      @prev
    end
    
    alias previous prev
    
    def prev!
      @prev
    end
    
    alias previous! prev!
  end
end
