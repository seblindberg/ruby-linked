module Linked
  class List
    class Tail
      attr_writer :prev
      
      alias previous= prev=
      
      def initialize
        @prev = nil
      end
      
      def nil?
        true
      end
      
      def prev
        raise StopIteration if @prev.nil?
        @prev
      end
      
      alias previous prev
    end
  end
end
