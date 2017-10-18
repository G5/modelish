# frozen_string_literal: true

require 'date'

module Modelish
  # Mixin for validated properties
  module Validations
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Validates all properties based on configured validators.
    #
    # @return [Hash<Symbol,Array>] map of errors where key is the property name
    #                              and value is the list of errors
    # @see ClassMethods#add_validator
    def validate
      errors = {}

      call_validators do |name, message|
        errors[name] ||= []
        errors[name] << to_error(message)
      end

      errors
    end

    # Validates all properties based on configured validators.
    #
    # @raise ArgumentError when any property fails validation
    def validate!
      errors = validate
      raise errors.first[1].first unless errors.empty?
    end

    def valid?
      validate.empty?
    end

    private

    def call_validators
      self.class.validators.each_pair do |property_name, validators|
        validators.each do |validator|
          message = validator.call(send(property_name))
          yield property_name, message if message
        end
      end
    end

    def to_error(msg)
      msg.is_a?(StandardError) ? msg : ArgumentError.new(msg.to_s)
    end

    # Class methods for managing validated properties
    module ClassMethods
      # Sets up a block containing validation logic for a given property.
      # Each property may have 0 or more validators.
      #
      # @param [String,Symbol] property_name the name of the property to
      #                                      validate
      # @param [#call] validator the block containing the validation logic; must
      #                          return either an error object or a string
      #                          containing the error message if validation
      #                          fails.
      #
      # @example adding a validator that only allows non-nil values
      #     class MyModel
      #       include Modelish::Validations
      #       attr_accessor :foo
      #       add_validator(:foo) { |val| val.nil? ? 'foo must exist': nil }
      #     end
      def add_validator(property_name, &validator)
        property = property_name.to_sym
        validators[property] ||= []
        validators[property] << validator

        class_eval do
          attr_accessor property unless method_defined?(property_name)
        end
      end

      # A map of registered validator blocks, keyed on property_name.
      def validators
        @validators ||= {}
      end

      # Validates the required values, returning a list of errors when
      # validation fails.
      #
      # @param [Hash] args the map of name => value pairs to validate
      # @return [Array<ArgumentError>] a list of validation failures
      def validate_required(args)
        blanks = args.select { |_k, v| v.nil? || v.to_s.strip.empty? }
        blanks.keys.map do |name|
          ArgumentError.new("#{name} must not be nil or blank")
        end
      end

      # Validates the required values, raising an error when validation fails.
      #
      # @param [Hash] args the map of name => value pairs to validate
      # @raise [ArgumentError] when any value in args hash is nil or empty.
      #                        The name key will be used to construct an
      #                        informative error message.
      def validate_required!(args)
        errors = validate_required(args)
        raise errors.first unless errors.empty?
      end

      # Validates the required values, returning a boolean indicating validation
      # success.
      #
      # @param [Hash] args the map of name => value pairs to validate
      # @return [true,false] true when validation passes; false when validation
      #                      fails
      def validate_required?(args)
        validate_required(args).empty?
      end

      # Validates the length of a value, raising an error to indicate validation
      # failure.
      #
      # @param (see .validate_length)
      # @raise [ArgumentError] when the value is longer than max_length
      def validate_length!(name, value, max_length)
        error = validate_length(name, value, max_length)
        raise error if error
      end

      # Validates the length of a value, returning a boolean to indicate
      # validation success.
      #
      # @param (see .validate_length)
      # @return [true,false] true if value does not exceed max_length; false
      #                      otherwise
      def validate_length?(name, value, max_length)
        validate_length(name, value, max_length).nil?
      end

      # Validates the length of a value, returning an error when validation
      # fails.
      #
      # @param [Symbol,String] name the property/argument to validate
      # @param [#length] value the value to be validated
      # @param [#to_i] max_length the maximum allowable length
      # @raise [ArgumentError] when the value is longer than max_length
      def validate_length(name, value, max_length)
        if max_length.to_i > 0 && value.to_s.length > max_length.to_i
          message = "#{name} must be less than #{max_length} characters"
          ArgumentError.new(message)
        end
      end

      # Validates the type of the value, returning a boolean indicating
      # validation outcome.
      #
      # @see #validate_type
      # @param {see #validate_type}
      # @return [true,false] true when the value is the correct type; false
      #                      otherwise
      def validate_type?(name, value, type)
        validate_type(name, value, type).nil?
      end

      # Validates the type of the value, raising an error when the value is not
      # of the correct type.
      #
      # @see #validate_type
      # @param {see #validate_type}
      # @raise [ArgumentError] when the value is not the correct type
      def validate_type!(name, value, type)
        error = validate_type(name, value, type)
        raise error if error
      end

      # Validates the type of the value, returning an error when the value
      # cannot be converted to the appropriate type.
      #
      # @param [Symbol,String] name the property/argument to validate
      # @param [Object] value the value to be validated
      # @param [Class,Proc] type the type of the class to validate.
      #   Supported types include:
      #     * +Integer+
      #     * +Float+
      #     * +Date+
      #     * +DateTime+
      #     * +Symbol+
      #     * any arbitrary +Class+ -- validates based on the results of is_a?
      # @return [ArgumentError] when validation fails
      def validate_type(name, value, type)
        error = nil

        begin
          if value && type
            # Can't use a case statement because of the way === is implemented on some classes
            if type == Integer
              is_valid = (value.is_a?(Integer) || value.to_s =~ /^\-?\d+$/)
            elsif type == Float
              is_valid = (value.is_a?(Float) || value.to_s =~ /^\-?\d+\.?\d*$/)
            elsif [Date, DateTime].include?(type)
              is_valid = value.is_a?(type) || (type.parse(value.to_s) rescue false)
            elsif type == Symbol
              is_valid = value.respond_to?(:to_sym)
            else
              is_valid = value.is_a?(type)
            end

            unless is_valid
              message = "#{name} must be of type #{type}, " \
                        "but got #{value.inspect}"
              error = ArgumentError.new(message)
            end
          end
        rescue StandardError => e
          message = "An error occurred validating #{name} with " \
                    "value #{value.inspect}: #{e.message}"
          error = ArgumentError.new(message)
        end

        error
      end
    end
  end
end
