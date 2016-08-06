# End Of List
#
# This class implements a special list item that is placed at both the end and
# the beginning of a chain of regular items to form a list. The naming (end of
# list) comes from the fact that this object, by returning true for calls to
# #nil?, signifies the end of a list of Items. In both directions as a matter of
# fact, which is why the head and tail objects defined by Item is combined into
# one.

module Linked
  module List
    class EOL < Item
      private :value, :value=, :delete, :first?, :last?
      
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
      
      # Inserts a
      
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