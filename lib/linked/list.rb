module Linked
  class List
    attr_reader :eol, :count
    def initialize(*)
      super
      
      @eol = EOL.new list: self
      @count = 0
    end
        
    def head
      eol
    end
    
    def tail
      eol
    end
    
    def first
      eol.next!
    end
    
    def last
      eol.prev!
    end
    
    def increment(n)
      @count += n
    end
    
    def decrement
      @count -= 1
    end
    
    def push(item)
      eol.append item
    end
    
    def pop
      last.delete
    end
    
    def unshift(item)
      eol.prepend item
    end
    
    def shift
      first.delete
    end
  end
end
