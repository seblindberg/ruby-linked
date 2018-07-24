# frozen_string_literal: true

module Linked
  # This is the default implementation of a listable object
  #
  # This class implements a listable value object that wraps an arbitrary value
  # an can be with other listable items.
  class Item
    include Listable

    # The Item can hold an arbitrary object as its value and it will stay with
    # the item.
    #
    # @return [Object] any object that is stored in the item.
    attr_accessor :value

    # Creates a new item. If a list is given the item will be considered a part
    # of that list and appended to the end of it.
    #
    # @param  value [Object] an arbitrary object to store with the item.
    def initialize(value = nil)
      @value = value
      super()
    end

    # Calling #dup on an item returns a copy that is no longer connected to the
    # original item chain. The value will also be copied.
    #
    # @param  source [Item] the item to copy.
    # @return [item] a new Item.
    def initialize_dup(source)
      @value = begin
                 source.value.dup
               rescue TypeError
                 source.value
               end
      super
    end

    # Item equality is solely determined by tha value. If the other object
    # responds to #value, and its value is equal (#==) to this value, the
    # objects are considered equal.
    #
    # @param  other [#value, Object] any object.
    # @return [true, false] true if the value of the given object is equal to
    #   the item value.
    def ==(other)
      return false unless other.respond_to? :value
      value == other.value
    end

    alias eql? ==

    # Uses the hash value of the item value.
    #
    # @return [Integer] a fixnum that can be used by Hash to identify the item.
    def hash
      value.hash
    end

    # Freezes the value, as well as making the item itself immutable.
    #
    # @return [self]
    def freeze
      value.freeze
      super
    end

    # The default #inspect method becomes very cluttered the moment you start
    # linking objects together. This implementation fixes that and only shows
    # the class name, object id and value (if set).
    #
    # @return [String] a string representation of the list item.
    def inspect
      return yield(self).to_s if block_given?
      value ? object_identifier + " value=#{value.inspect}" : object_identifier
    end
  end
end
