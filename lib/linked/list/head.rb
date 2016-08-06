module Linked
  class List
    class Head
      attr_writer :next
      
      def initialize
        @next = nil
      end
      
      # Head objects will return true when asked if they are nil. This is
      # foremost an implementation detail to comply with the requirements of the
      # Item class, but also logical in the sense that Head objects are not
      # really part of the list, and should therefore be considered nil.
      #
      # Returns true.
      
      def nil?
        true
      end
      
      # Access the first item in the list. If the list is empty a StopIteration
      # will be raised.
      #
      # Returns the first list item.
      
      def next
        raise StopIteration if @next.nil?
        @next
      end
      
      def next!
        @next
      end
    end
  end
end
