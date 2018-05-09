# frozen_string_literal: true

module Linked
  # Collection of common utility methods.
  module Util
    protected def object_identifier
      format '%s:0x%0x', self.class.name, object_id
    end
  end
end
