require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'linked'

require 'minitest/autorun'

class ListLike
  include Linked::List
end
