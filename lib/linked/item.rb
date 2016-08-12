# frozen_string_literal: true

module Linked
  # Item
  #
  # This class implements a listable value object that wraps an arbitrary object
  # an can be stored in a list.
  
  class Item
    include Listable

    # The Item can hold an arbitrary object as its value and it will stay with
    # the item.

    attr_accessor :value

    # Creates a new item. If a list is given the item will be considered a part
    # of that list and appended to the end of it.
    #
    # value - an arbitrary object to store with the item.
    # list - an object responding to #head and #tail.
    #
    # Returns a new Item.

    def initialize(value = nil, list: nil)
      @value = value
      super()
    end

    # Calling #dup on an item returns a copy that is no longer connected to the
    # original item chain, or the list. The value will also be copied.
    #
    # Returns a new Item.

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
    # other - any object.
    #
    # Returns true if the objects are considered equal.
    
    def ==(other)
      return false unless other.respond_to? :value
      value == other.value
    end
    
    alias eql? ==
    
    # Uses the hash value of the item value.
    #
    # Returns a fixnum that can be used by Hash to identify the item.
    
    def hash
      value.hash
    end

    # Freezes the value, as well as making the list item itself immutable.

    def freeze
      value.freeze
      super
    end

    # The default #inspect method becomes very cluttered the moment you start
    # liking objects together. This implementation fixes that and only shows the
    # class name, object id and value (if set).

    def inspect
      return yield self if block_given?

      output = format '%s:0x%0x', self.class.name, object_id
      value ? output + " value=#{value.inspect}" : output
    end
  end
end
