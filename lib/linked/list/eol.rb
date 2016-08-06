module Linked
  class List
    class EOL < Item
      private :value, :value=, :delete
      
      def initialize(list:)
        super()
        @list = list
        @prev = @next = self
      end
      
      # EOL objects will return true when asked if they are nil. This is
      # foremost an implementation detail to comply with the requirements of the
      # Item class, but also logical in the sense that end-of-list objects are
      # not really part of the list, and should therefore be considered nil.
      #
      # Returns true.
      
      def nil?
        true
      end
      
      def append(sibling)
        if @prev == self
          super
        else
          @prev.append sibling
        end
      end
      
      def prepend(sibling)
        if @next == self
          super
        else
          @next.prepend sibling
        end
      end
    end
  end
end