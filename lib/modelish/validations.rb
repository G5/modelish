require 'date'

module Modelish
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
 
      call_validators do |name,message|
        errors[name] ||= []
        errors[name] << to_error(message)
      end

      errors
    end

    # Validates all properties based on configured validators.
    #
    # @raise ArgumentError when any property fails validation
    def validate!
      call_validators do |name,message| 
        error = to_error(message)
        raise error if error
      end
      nil
    end

    def valid?
      validate.empty?
    end

    private
    def call_validators(&error_handler)
      self.class.validators.each_pair do |k,v|
        v.each do |prop_validator|
          if msg = prop_validator.call(self.send(k))
            error_handler.call(k, msg)
          end
        end
      end
    end

    def to_error(msg)
      msg.is_a?(StandardError) ? msg : ArgumentError.new(msg.to_s)
    end

    module ClassMethods
      # Sets up a block containing validation logic for a given property.
      # Each property may have 0 or more validators.
      #
      # @param [String,Symbol] property_name the name of the property to validate
      # @param [#call] validator the block containing the validation logic; must return
      #                          either an error object or a string containing the error
      #                          message if validation fails.
      # 
      # @example adding a validator that only allows non-nil values
      #     class MyModel
      #       include Modelish::Validations
      #       attr_accessor :foo
      #       add_validator(:foo) { |val| val.nil? ? 'foo must not be nil': nil }
      #     end
      def add_validator(property_name, &validator)
        validators[property_name.to_sym] ||= [] 
        validators[property_name.to_sym] << validator

        class_eval do
          attr_accessor property_name.to_sym unless method_defined?(property_name.to_sym)
        end
      end

      # A map of registered validator blocks, keyed on property_name.
      def validators
        @validators ||= {}
      end

      # Validates the required values, returning a list of errors when validation
      # fails.
      #
      # @param [Hash] args the map of name => value pairs to validate
      # @return [Array<ArgumentError>] a list of ArgumentErrors for validation failures.
      def validate_required(args)
        errors = []
        args.each do |name, value|
          errors << ArgumentError.new("#{name} must not be nil or blank") if value.nil? || value.to_s.strip.empty?
        end
        errors
      end

      # Validates the required values, raising an error when validation fails.
      #
      # @param [Hash] args the map of name => value pairs to validate
      # @raise [ArgumentError] when any value in args hash is nil or empty. The name
      #                        key will be used to construct an informative error message.
      def validate_required!(args)
        errors = validate_required(args)
        raise errors.first unless errors.empty?
      end

      # Validates the required values, returning a boolean indicating validation success.
      #
      # @param [Hash] args the map of name => value pairs to validate
      # @return [true,false] true when validation passes; false when validation fails
      def validate_required?(args)
        validate_required(args).empty?
      end

      # Validates the length of a value, raising an error to indicate validation failure.
      #
      # @param (see .validate_length)
      # @raise [ArgumentError] when the value is longer than max_length
      def validate_length!(name, value, max_length)
        error = validate_length(name, value, max_length)
        raise error if error
      end

      # Validates the length of a value, returning a boolean to indicate validation
      # success.
      #
      # @param (see .validate_length)
      # @return [true,false] true if value does not exceed max_length; false otherwise
      def validate_length?(name, value, max_length)
        validate_length(name, value, max_length).nil?
      end

      # Validates the length of a value, returning an error when validation fails.
      #
      # @param [Symbol,String] name the name of the property/argument to be validated
      # @param [#length] value the value to be validated
      # @param [#to_i] max_length the maximum allowable length
      # @raise [ArgumentError] when the value is longer than max_length
      def validate_length(name, value, max_length)
        if max_length.to_i > 0 && value.to_s.length > max_length.to_i
          ArgumentError.new("#{name} must be less than #{max_length} characters")
        end
      end
    end
  end
end
