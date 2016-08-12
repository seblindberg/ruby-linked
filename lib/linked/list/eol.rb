module Linked
  class List
    # End Of List
    #
    # This class implements a special list item that is placed at both the end
    # and the beginning of a chain of listable items to form a list. The naming
    # (end of list) comes from the fact that this object, by returning true for
    # calls to #nil?, signifies the end of a list of Items. In both directions
    # as a matter of fact, which is why the head and tail objects defined by
    # Item are combined into one.
    #
    # In a nutshell, the structure looks something like this:
    #
    #   +-------------------- EOL --------------------+
    #   | (head)                               (tail) |
    #   +---------------------------------------------+
    #     ^ +-- Item 1 ---+         +-- Item N ---+ ^
    #     +-| prev | next |<- ... ->| prev | next |-+
    #       +------+------+         +------+------+

    class EOL
      include Listable

      # Calling #delete on the EOL is not supported and would break the
      # connection between the list and its items.

      undef delete

      # Creates a new enf-of-list, as part of a list, with no items yet added to
      # it.
      #
      # list - a List object.

      def initialize(list)
        super()
        self.list = list
        reset
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

      # Inserts one or more items at the end of the list.
      #
      # See Item#append for more details.

      def append(object)
        empty? ? super : prev!.append(object)
      end

      # Inserts one or more items at the beginning of the list.
      #
      # See Item#append for more details.

      def prepend(object)
        empty? ? super : next!.prepend(object)
      end

      # Private helper to reset the EOL to its initial state. This method should
      # never be called directly as it leaves the both the list and the items in
      # an inconsistant state.

      private def reset
        self.prev = self.next = self
      end

      # Private helper to check if the item chain is empty.
      #
      # Return true if the chain is empty, otherwise nil.

      private def empty?
        prev!.equal? self
      end
    end
  end
end