# frozen_string_literal: true

module Modelish
  # Configure modelish's behavior on a global level
  module Configuration
    # If true, ignore unknown property names when initializing new models;
    # otherwise, raise an error when an unknown property is encountered.
    # Defaults to false.
    attr_accessor :ignore_unknown_properties

    # When set, unknown property names will be ignored during initialization
    # and property setting.
    #
    # @see {raise_errors_on_unknown_properties!}
    def ignore_unknown_properties!
      self.ignore_unknown_properties = true
    end

    # When set, raise errors during initialization and property setting when
    # unknown property names are encountered. This is the default.
    #
    # @see {ignore_unknown_properties!}
    def raise_errors_on_unknown_properties!
      self.ignore_unknown_properties = false
    end

    # When this module is extended, set all configuration options to their
    # default values
    def self.extended(base)
      base.reset
    end

    # Configures this module through the given +block+.
    # Default configuration options will be applied unless
    # they are explicitly overridden in the +block+.
    #
    # @example Disable raising errors on unknown property names
    #   Modelish.configure do |config|
    #     config.ignore_unknown_properties = true
    #   end
    def configure
      yield self if block_given?
      self
    end

    # Resets this module's configuration.
    def reset
      self.ignore_unknown_properties = false
    end
  end
end
