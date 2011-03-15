require 'hashie'
require 'property_types'

module Modelish
  class Base < Hashie::Trash
    include PropertyTypes

    def self.property(name, options={})
      super

      if options[:type]
        add_property_type(name, options[:type])
      end
    end
  end
end
