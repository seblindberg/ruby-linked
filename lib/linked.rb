# frozen_string_literal: true

require 'forwardable'

require 'linked/version'
require 'linked/util'
require 'linked/mutable'
require 'linked/listable'
require 'linked/item'
require 'linked/list_enumerable'
require 'linked/list'

# Linked List implementation.
module Linked
  private_constant :Util, :ListEnumerable, :Mutable
end
