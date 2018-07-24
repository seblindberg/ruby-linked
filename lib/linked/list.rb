# frozen_string_literal: true

module Linked
  # This class provides a way extend the regular chain of listable items with
  # the concept of an empty chain.
  #
  # Lists are ment to behave more like arrays, and respond to many of the same
  # methods.
  class List
    include ListEnumerable
    include Util

    # Initializes the list.
    def initialize
      reset_list
      super
    end

    # When copying a list its entire item chain needs to be copied as well.
    # Therefore #dup will be called on each of the original lists items, making
    # this operation quite expensive.
    #
    # @param source [List] the list to copy.
    def initialize_dup(source)
      reset_list
      source.each_item { |item| push item.dup }

      super
    end

    # Access the first item in the list. If the list is empty a NoMethodError
    # will be raised. This mirrors the behaviour of Item#item and allows other
    # methods that work on List objects to easily and interchangeably accept
    # both lists and items as arguments.
    #
    # @return [Listable] the first item in the list.
    def item
      raise NoMethodError if empty?
      @_chain
    end

    # Two lists are considered equal if the n:th item from each list are equal.
    #
    # @param  other [Object] the object to compare with.
    # @return [true] if the given object is a list and the items are equal.
    # @return [false] otherwise.
    def ==(other)
      return false unless other.is_a? self.class
      return false unless other.count == count

      other_items = other.each_item
      each_item.all? { |item| item == other_items.next }
    end

    alias eql? ==

    # @return [true] if the list does not contain any items.
    # @return [false] otherwise.
    def empty?
      nil.eql? @_chain
    end

    # Insert an item at the end of the list. If the given object is not an
    # object responding to #item it will be treated as a value. The value will
    # be wraped in a new Item create by #create_item.
    #
    # See Item#append for more details.
    #
    # @param object [#item, Object] the item to insert, or an arbitrary object.
    # @return [self]
    def push(object)
      item = coerce_item object

      if empty?
        @_chain = item
      else
        list_tail.append item
      end

      self
    end

    alias << push

    # Pop the last item off the list.
    #
    # @return [Listable, nil] the last item in the list, or nil if the list is
    #   empty.
    def pop
      return nil if empty?

      list_tail.first? ? last.tap { @_chain = nil } : list_tail.delete
    end

    # Insert an item at the beginning of the list. If the given object is not an
    # object responding to #item it will be treated as a value. The value will
    # be wraped in a new Item create by #create_item.
    #
    # See Item#prepend for more details.
    #
    # @param object [#item, Object] the item to insert, or an arbitrary object.
    # @return [self]
    def unshift(object)
      item = coerce_item object
      @_chain = empty? ? item.chain : @_chain.prepend(item)

      self
    end

    # Shift the first item off the list.
    #
    # @return [Listable, nil] the first item in the list, or nil if the list is
    #   empty.
    def shift
      return nil if empty?

      if list_head.last?
        @_chain.tap { @_chain = nil }
      else
        old_head = list_head
        @_chain = list_head.next
        old_head.delete
      end
    end

    # Check if an item is in the list.
    #
    # @param  item [Object] any object that may be in the list.
    # @return [true] if the given item is in the list.
    # @return [false] otherwise.
    def include?(item)
      return false if empty?
      # TODO: This works fine, but looks wrong.
      @_chain.in_chain? item
    end

    # Calls #freeze on all items in the list, as well as the head and the tail
    # (eol).
    #
    # @return [self]
    def freeze
      each_item(&:freeze)
      super
    end

    # Overrides the default inspect method to provide a more useful view of the
    # list.
    #
    # Importantly this implementation supports nested lists and will return a
    # tree like structure.

    def inspect_list(&block)
      res = [block_given? ? yield(self) : object_identifier]

      each_item do |item|
        lines = item.inspect(&block).split "\n"

        res.push((item.last? ? '└─╴' : '├─╴') + lines.shift)
        padding = item.last? ? '   ' : '│  '
        lines.each { |line| res.push padding + line }
      end

      res.join("\n")
    end

    alias inspect inspect_list

    protected

    # Protected factory method for creating items compatible with the list. This
    # method is called whenever an arbitrary object is pushed or unshifted onto
    # the list and need to be wraped inside an Item.
    #
    # This method can be overridden to support different Item types.
    #
    # @param  args [Array<Object>] the arguments that are to be passed on to
    #   `Item.new`.
    # @return [Item] a new `Listable` item.
    def create_item(*args)
      Item.new(*args)
    end

    private

    # Takes an arbitrary object and coerces it into an item compliant with the
    # list. If the object is already an item it will be used as is. Otherwise
    # #create_item will be called with the object as an argument.
    #
    # @param  [#item, Object] the object to coerce.
    # @return [Listable] see `#create_item`.
    def coerce_item(object)
      object.respond_to?(:item) ? object.item : create_item(object)
    end

    # Private method for clearing the list and bringing it to a pristine
    # state.
    def reset_list
      @_chain = nil
    end

    # Returns the first item item in the list, or nil if empty.
    def list_head
      @_chain
    end

    # Returns an the last item in the list, or nil if empty.
    def list_tail
      @_chain.last_in_chain
    end
  end
end
