require 'hashie'
require 'modelish/property_translations'
require 'modelish/property_types'
require 'modelish/validations'
require 'modelish/configuration'

module Modelish
  class Base < Hashie::Dash
    include PropertyTranslations
    include PropertyTypes
    include Validations
    extend Configuration

    def initialize(options={}, &block)
      super(&block)

      attributes = options ? options.dup : {}

      attributes.delete_if do |k,v|
        if self.class.translations.keys.include?(k.to_sym)
          self[k]=v
          true
        end
      end

      attributes.each_pair do |att, value|
        self[att] = value
      end
    end

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
    #                                      value's presence; nil or blank values
    #                                      will cause validation methods to fail
    # @option opts [Integer] :max_length the maximum allowable length for a valid
    #                                     property value
    # @option opts [true,false] :validate_type enables validation for the property value's
    #                                           type based on the :type option
    # @option opts [Proc] :validator A block that accepts a value and validates it;
    #                                 should return nil if validation passes, or an error
    #                                 message or error object if validation fails.
    #                                 See {Modelish::Validations}
    def self.property(name, options={})

      #Hashie::Dash.property is going to delete :required from the options hash
      required = options[:required]

      super

      add_property_type(name, options[:type]) if options[:type]
      add_property_translation(options[:from], name) if options[:from]

      add_validator(name) { |val| validate_required(name => val).first } if required
      add_validator(name) { |val| validate_length(name, val, options[:max_length]) } if options[:max_length]
      add_validator(name, &options[:validator]) if options[:validator]
      add_validator(name) { |val| validate_type(name, val, options[:type]) } if options[:validate_type]
    end

    # Convert this Modelish object into a vanilla Hash with stringified keys.
    #
    # @return [Hash] the hash of properties
    def to_hash
      out = {}
      self.class.properties.each do |p|
        val = self.send(p)
        if val.is_a?(Array)
          out[p.to_s]||=[]
          out[p.to_s].concat(val.collect{|x|x.respond_to?(:to_hash) ? x.to_hash : x})
        else
          out[p.to_s] = val.respond_to?(:to_hash) ? val.to_hash : val
        end
      end
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

    def assert_required_properties_set!
      true
    end

    def assert_property_required!
      true
    end

    def property_exists?(property)
      if self.class.property?(property.to_sym)
        true
      elsif self.class.ignore_unknown_properties || 
            (self.class.ignore_unknown_properties.nil? && Modelish.ignore_unknown_properties)
        false
      else
        raise NoMethodError, "The property '#{property}' is not defined for this Modelish object."
      end
    end
  end
end
