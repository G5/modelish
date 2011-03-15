require 'date'

module Modelish
  # Mixes in behavior for automatically converting property types.
  module PropertyTypes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Adds a typed property to the model.
      # This dynamically generates accessor/mutator methods that perform
      # the appropriate type conversions on the property's value.
      # 
      # Generated methods:
      # * +<property_name>=(new_value)+ -- sets the property value. 
      # * +<property_name>+ -- returns the property value, converted to the configured
      #                        type. If the value cannot be converted, no error will be
      #                        raised, and the raw unconverted value will be returned.
      # * +<property_name>!+ -- returns the property value, converted to the configured
      #                         type. If the value cannot be converted, a TypeError will
      #                         be raised.
      # * +raw_<property_name> -- the original property value, without any type conversions.
      # 
      # @param [Symbol] property_name the name of the property.
      # @param [Class, Proc] property_type the type of the property's value.
      #                                    Valid types include:
      #   * +Integer+
      #   * +Float+
      #   * +Array+
      #   * +Date+ -- converts using Date.parse on value.to_s
      #   * +Symbol+ -- also converts from camel case to snake case
      #   * +String+
      #   * any arbitrary +Class+ -- will attempt conversion by passing the raw
      #                              value into the class's initializer
      #   * an instance of +Proc+ -- will convert the value by executing the proc,
      #                              passing in the raw value as an argument
      def add_property_type(property_name, property_type=String)
        property_types[property_name] = property_type

        converter = value_converter(property_type)

        class_eval do
          attr_reader property_name.to_sym unless method_defined?(property_name.to_sym)
          attr_writer property_name.to_sym unless method_defined?("#{property_name}=".to_sym)

          alias_method("raw_#{property_name}".to_sym, property_name.to_sym)

          define_method("#{property_name}!".to_sym) do
            value = self.send("raw_#{property_name}")
            (converter && value) ? converter.call(value) : value
          end

          define_method(property_name.to_sym) do
            self.send("#{property_name}!".to_sym) rescue self.send("raw_#{property_name}")
          end
        end
      end

      def property_types
        @property_types ||= {}
      end

      private
      def value_converter(property_type)
        if property_type == Date
          lambda { |val| Date.parse(val.to_s) }
        elsif property_type == Symbol
          lambda { |val| val.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2').
                                          gsub(/([a-z\d])([A-Z])/, '\\1_\\2').
                                          gsub(/\s+|-/,'_').downcase.to_sym }
        elsif Kernel.respond_to?(property_type.to_s) 
          lambda { |val| Kernel.send(property_type.to_s, val) }
        elsif property_type.respond_to?(:call)
          property_type
        else
          lambda { |val| property_type.new(val) }
        end
      end
    end
  end
end
