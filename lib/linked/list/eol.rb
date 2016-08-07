module Linked
  module List
    # End Of List
    #
    # This class implements a special list item that is placed at both the end
    # and the beginning of a chain of regular items to form a list. The naming
    # (end of list) comes from the fact that this object, by returning true for
    # calls to #nil?, signifies the end of a list of Items. In both directions
    # as a matter of fact, which is why the head and tail objects defined by
    # Item is combined into one.
    #
    # In a nutshell, the structure looks something like this:
    #
    #   +-------------------- EOL --------------------+
    #   | (head)                               (tail) |
    #   +---------------------------------------------+
    #     ^ +-- Item 1 ---+         +-- Item N ---+ ^
    #     +-| prev | next |<- ... ->| prev | next |-+
    #       +------+------+         +------+------+

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

      # Inserts one or more items at the end of the list. If the given object is
      # not an Item, or a decendant of Item, it will be treated as a value.
      # Depending on the state of the list the value will be
      # a) wraped in a new instance of Item if the list is empty or
      # b) wraped in an object of the same class as the last item in the list.
      #
      # sibling - the item or value to be appended.
      #
      # Returns the item that was appended. In case of a string of items the
      # last one is returned.

      def append(sibling)
        if @prev == self
          sibling = Item.new sibling unless sibling.is_a? Item
          super sibling
        else
          @prev.append sibling
        end
      end

      # Inserts one or more items at the beginning of the list. If the given
      # object is not an Item, or a decendant of Item, it will be treated as a
      # value. Depending on the state of the list the value will be
      # a) wraped in a new instance of Item if the list is empty or
      # b) wraped in an object of the same class as the last item in the list.
      #
      # sibling - the item or value to be prepended.
      #
      # Returns the item that was prepended. In case of a string of items the
      # first one is returned.

      def prepend(sibling)
        if @next == self
          sibling = Item.new sibling unless sibling.is_a? Item
          super sibling
        else
          @next.prepend sibling
        end
      end
    end
  end
end