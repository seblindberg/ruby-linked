module Linked
  class List
    class Head
      attr_writer :next
      
      def initialize
        @next = nil
      end
      
      def nil?
        true
      end
      
      def next
        raise StopIteration if @next.nil?
        @next
      end
    end
  end
end
