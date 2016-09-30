require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'linked'

require 'custom_assertions'
require 'minitest/autorun'
