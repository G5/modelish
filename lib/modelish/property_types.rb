# frozen_string_literal: true

require 'date'

module Modelish
  # Mixes in behavior for automatically converting property types.
  module PropertyTypes
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods for managing typed properties
    module ClassMethods
      # Adds a typed property to the model.
      # This dynamically generates accessor/mutator methods that perform
      # the appropriate type conversions on the property's value.
      #
      # Generated methods:
      # * +<property_name>=(new_value)+ -- sets the property value.
      # * +<property_name>+ -- returns the property value, converted to the
      #                        configured type. If the value cannot be
      #                        converted, no error will be raised, and the raw
      #                        unconverted value will be returned.
      # * +<property_name>!+ -- returns the property value, converted to the
      #                         configured type. If the value cannot be
      #                         converted, a TypeError will be raised.
      # * +raw_<property_name> -- the original property value, without any type
      #                           conversions.
      #
      # @param [Symbol] property_name the name of the property.
      # @param [Class, Proc] property_type the type of the property's value.
      #                                    Valid types include:
      #   * +Integer+
      #   * +Float+
      #   * +Array+
      #   * +Date+ -- converts using Date.parse on value.to_s
      #   * +DateTime+ -- converts using DateTime.parse on value.to_s
      #   * +Symbol+ -- also converts from camel case to snake case
      #   * +String+
      #   * any arbitrary +Class+ -- will attempt conversion by passing the raw
      #                              value into the class's initializer
      #   * an instance of +Proc+ -- will convert the value by executing the
      #                              proc, passing in the raw value
      def add_property_type(property_name, property_type = String)
        accessor = property_name.to_sym
        return if property_types[accessor] == property_type

        # TODO: Refactor. This method is getting unwieldy as more
        # corner cases are discovered. A few well-placed design
        # refinements should take care of it (now we just need to figure
        # out what those are.)
        property_types[accessor] = property_type

        raw_accessor = define_raw_accessor(accessor)
        bang_accessor = define_bang_accessor(accessor)

        typed_accessor = "_typed_#{accessor}".to_sym
        typed_mutator = "#{typed_accessor}=".to_sym
        to_safe = "_to_safe_#{accessor}".to_sym

        class_eval do
          remove_method(typed_accessor) if method_defined?(typed_accessor)
          remove_method(typed_mutator) if method_defined?(typed_mutator)
          attr_accessor typed_accessor
          protected typed_accessor, typed_mutator

          remove_method(to_safe) if method_defined?(to_safe)
          define_method(to_safe) do
            begin
              send(bang_accessor)
            rescue
              send(raw_accessor)
            end
          end
          protected to_safe

          remove_method(accessor) if method_defined?(accessor)
          define_method(accessor) do
            val = send(typed_accessor)

            unless val || send(raw_accessor).nil?
              val = send(to_safe)
              send(typed_mutator, val)
            end

            val
          end

          remove_method("#{accessor}=") if method_defined?("#{accessor}=")
          define_method("#{accessor}=") do |val|
            send("#{raw_accessor}=", val)
            send(typed_mutator, send(to_safe))
          end
        end
      end

      def property_types
        @property_types ||= {}
      end

      private

      def define_raw_accessor(name)
        accessor = name.to_sym
        raw_accessor = "raw_#{name}".to_sym

        mutator = "#{name}=".to_sym
        raw_mutator = "raw_#{name}=".to_sym

        class_eval do
          unless method_defined?(raw_accessor) && method_defined?(raw_mutator)
            if method_defined?(accessor) && method_defined?(mutator)
              alias_method(raw_accessor, accessor)
              alias_method(raw_mutator, mutator)
            else
              attr_accessor raw_accessor
            end
          end
        end

        raw_accessor
      end

      def define_bang_accessor(property_name)
        bang_accessor = "#{property_name}!".to_sym
        converter = value_converter(property_types[property_name.to_sym])

        class_eval do
          remove_method(bang_accessor) if method_defined?(bang_accessor)
          define_method(bang_accessor) do
            value = send("raw_#{property_name}")
            converter && value ? converter.call(value) : value
          end
        end

        bang_accessor
      end

      def value_converter(property_type)
        if [Date, DateTime].include?(property_type)
          ->(val) { property_type.parse(val.to_s) }
        elsif property_type == Symbol
          lambda do |val|
            val.to_s.strip.gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2')
               .gsub(/([a-z\d])([A-Z])/, '\\1_\\2')
               .gsub(/\s+|-/, '_').downcase.to_sym
          end
        elsif property_type == String
          ->(val) { val.to_s.strip }
        elsif Kernel.respond_to?(property_type.to_s)
          ->(val) { Kernel.send(property_type.to_s, val) }
        elsif property_type.respond_to?(:call)
          property_type
        else
          ->(val) { property_type.new(val) }
        end
      end
    end
  end
end
