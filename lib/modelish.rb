# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('modelish', File.dirname(__FILE__)))

require 'modelish/version'
require 'modelish/base'
require 'modelish/configuration'

module Modelish
  extend Configuration
end
