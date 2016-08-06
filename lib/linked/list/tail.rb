module Linked
  class List
    class Tail
      attr_writer :prev
      
      alias previous= prev=
      
      def initialize
        @prev = nil
      end
      
      # Tail objects will return true when asked if they are nil. This is
      # foremost an implementation detail to comply with the requirements of the
      # Item class, but also logical in the sense that Tail objects are not
      # really part of the list, and should therefore be considered nil.
      #
      # Returns true.
      
      def nil?
        true
      end
      
      # Access the last item in the list. If the list is empty a StopIteration
      # will be raised.
      #
      # Returns the last list item.
      
      def prev
        raise StopIteration if @prev.nil?
        @prev
      end
      
      alias previous prev
    end
  end
end
