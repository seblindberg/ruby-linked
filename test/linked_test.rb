# frozen_string_literal: true

require 'test_helper'

describe Linked do
  subject { ::Linked }

  it 'has a version number' do
    refute_nil subject::VERSION
  end
end
