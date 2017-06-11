# frozen_string_literal: true

require 'hashie'
require 'modelish/property_translations'
require 'modelish/property_types'
require 'modelish/validations'
require 'modelish/configuration'

module Modelish
  # Base class for all modelish objects
  class Base < Hashie::Dash
    include PropertyTranslations
    include PropertyTypes
    include Validations
    extend Configuration

    def initialize(options = {}, &block)
      super(&block)

      attributes = options ? options.dup : {}
      init_attributes(attributes)
    end

    # Convert this Modelish object into a vanilla Hash with stringified keys.
    #
    # @return [Hash] the hash of properties
    def to_hash
      out = {}
      self.class.properties.each { |p| out[hash_key(p)] = hash_value(p) }
      out
    end

    def []=(property, value)
      if self.class.translations.keys.include?(property.to_sym)
        send("#{property}=", value)
      elsif property_exists?(property)
        super
      end
    end

    private

    def init_attributes(attributes)
      attributes.delete_if do |k, v|
        if self.class.translations.keys.include?(k.to_sym)
          self[k] = v
          true
        end
      end

      attributes.each_pair do |att, value|
        self[att] = value
      end
    end

    def property_exists?(property)
      if self.class.property?(property.to_sym)
        true
      elsif self.class.ignore_unknown_properties ||
            (self.class.ignore_unknown_properties.nil? &&
             Modelish.ignore_unknown_properties)
        false
      else
        raise NoMethodError, "The property '#{property}' is not defined for " \
                             'this Modelish object.'
      end
    end

    # Disable the various ways that hashie tries to assert required properties
    # are set on initialization (modelish defers this until validation)
    def assert_required_properties_set!; end

    def assert_property_required!(_property, _value); end

    def assert_required_attributes_set!; end

    def assert_property_exists!(property)
      property_exists?(property)
    end

    def hash_key(property)
      property.to_s
    end

    def hash_value(property)
      val = send(property).dup

      if val.is_a?(Array)
        val.map { |x| x.respond_to?(:to_hash) ? x.to_hash : x }
      else
        val.respond_to?(:to_hash) ? val.to_hash : val
      end
    end

    class << self
      # Creates a new attribute.
      #
      # @param [Symbol] name the name of the property
      # @param [Hash] options configuration for the property
      # @option opts [Object] :default the default value for this property
      #                                when the value has not been explicitly
      #                                set (defaults to nil)
      # @option opts [#to_s] :from the original key name for this attribute
      #                            (created as write-only)
      # @option opts [Class,Proc] :type the type of the property value. For
      #                                 a list of accepted types, see
      #                                 {Modelish::PropertyTypes}
      # @option opts [true,false] :required enables validation for the property
      #                                      value's presence; nil or blank
      #                                      will cause validation to fail
      # @option opts [Integer] :max_length the maximum allowable length for a
      #                                     valid property value
      # @option opts [true,false] :validate_type enables validation for the
      #                                           property value's type based on
      #                                           the :type option
      # @option opts [Proc] :validator A block that validates a value;
      #                                 returns nil if validation passes, or an
      #                                 error message or error object if
      #                                 validation fails.
      #                                 See {Modelish::Validations}
      def property(name, options = {})
        # Hashie::Dash.property is going to delete keys from the options
        opts = options.dup
        super

        add_property_type(name, opts[:type]) if opts[:type]
        add_property_translation(opts[:from], name) if opts[:from]

        process_required(name, opts)
        process_max_length(name, opts)
        process_validate_type(name, opts)

        add_validator(name, &opts[:validator]) if opts[:validator]
      end

      private

      def process_required(name, options)
        return unless options[:required] &&
                      (respond_to?(:required?) && required?(name))
        add_validator(name) { |val| validate_required(name => val).first }
      end

      def process_max_length(name, options)
        return unless options[:max_length]
        add_validator(name) do |val|
          validate_length(name, val, options[:max_length])
        end
      end

      def process_validate_type(name, options)
        return unless options[:validate_type]
        add_validator(name) do |val|
          validate_type(name, val, options[:type])
        end
      end
    end
  end
end
