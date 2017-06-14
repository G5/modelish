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

        property_types[accessor] = property_type

        # Protected attributes used during type conversion
        define_raw_attribute(accessor)
        define_bang_attribute(accessor)
        define_typed_attribute(accessor)
        define_safe_attribute(accessor)

        define_public_attribute(accessor)
      end

      def property_types
        @property_types ||= {}
      end

      private

      def typed_accessor(name)
        "_typed_#{name}".to_sym
      end

      def define_typed_attribute(name)
        typed_accessor = typed_accessor(name)
        typed_mutator = "#{typed_accessor}=".to_sym

        class_eval do
          remove_method(typed_accessor) if method_defined?(typed_accessor)
          remove_method(typed_mutator) if method_defined?(typed_mutator)

          attr_accessor typed_accessor
          protected typed_accessor, typed_mutator
        end
      end

      def safe_accessor(name)
        "_to_safe_#{name}".to_sym
      end

      def define_safe_attribute(name)
        safe_accessor = safe_accessor(name)
        bang_accessor = bang_accessor(name)
        raw_accessor = raw_accessor(name)

        class_eval do
          remove_method(safe_accessor) if method_defined?(safe_accessor)
          define_method(safe_accessor) do
            # Yes, we really do want to use inline rescue here, as this
            # method should always try to return *something*
            send(bang_accessor) rescue send(raw_accessor)
          end
          protected safe_accessor
        end
      end

      def define_public_reader(name)
        typed_accessor = typed_accessor(name)
        safe_accessor = safe_accessor(name)

        class_eval do
          remove_method(name) if method_defined?(name)
          define_method(name) do
            send(typed_accessor) ||
              send("#{typed_accessor}=", send(safe_accessor))
          end
        end
      end

      def define_public_writer(name)
        typed_accessor = typed_accessor(name)
        safe_accessor = safe_accessor(name)
        raw_accessor = raw_accessor(name)

        class_eval do
          remove_method("#{name}=") if method_defined?("#{name}=")
          define_method("#{name}=") do |val|
            send("#{raw_accessor}=", val)
            send("#{typed_accessor}=", send(safe_accessor))
          end
        end
      end

      def define_public_attribute(name)
        define_public_reader(name)
        define_public_writer(name)
      end

      def raw_accessor(name)
        "raw_#{name}".to_sym
      end

      def define_raw_attribute_reader(name)
        raw_accessor = raw_accessor(name)

        class_eval do
          unless method_defined?(raw_accessor)
            if method_defined?(name)
              alias_method(raw_accessor, name)
            else
              attr_reader raw_accessor
            end
          end
        end
      end

      def define_raw_attribute_writer(name)
        raw_accessor = raw_accessor(name)

        class_eval do
          unless method_defined?("#{raw_accessor}=")
            if method_defined?("#{name}=")
              alias_method("#{raw_accessor}=", "#{name}=")
            else
              attr_writer raw_accessor
            end
          end
        end
      end

      def define_raw_attribute(name)
        define_raw_attribute_reader(name)
        define_raw_attribute_writer(name)
      end

      def bang_accessor(name)
        "#{name}!".to_sym
      end

      def define_bang_attribute(name)
        bang_accessor = bang_accessor(name)
        raw_accessor = raw_accessor(name)
        converter = value_converter(property_types[name])

        class_eval do
          remove_method(bang_accessor) if method_defined?(bang_accessor)
          define_method(bang_accessor) do
            value = send(raw_accessor)
            converter && value ? converter.call(value) : value
          end
        end
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
