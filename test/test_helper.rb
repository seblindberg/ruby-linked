# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start 'test_frameworks'

require 'linked'

require 'custom_assertions'
require 'minitest/autorun'
