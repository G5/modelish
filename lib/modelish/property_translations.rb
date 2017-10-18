# frozen_string_literal: true

module Modelish
  # Mixin behavior for mapping one property name to another
  module PropertyTranslations
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Methods for managing a dictionary of property translations
    module ClassMethods
      # Adds a property translation to the model.
      # This maps a mutator name to an existing property,
      # so that whenever the from_name mutator is called on the
      # model, the to_name property receives the value. If subsequent
      # method calls add more destinations for the same source from_name,
      # all destination properties will be updated.
      #
      # @example A one-to-one property translation
      #    class MyClass
      #      include Modelish::PropertyTranslations
      #
      #      attr_accessor :foo
      #
      #      add_property_translation(:camelFoo, :foo)
      #    end
      #
      #    model = MyClass.new
      #    model.camelFoo = 'some value'
      #    model.foo
      #    # => "some value"
      #
      # @example A one-to-many property translation
      #    class
      #      include ModelisH::PropertyTranslations
      #
      #      attr_accessor :foo, :bar
      #
      #      add_property_translation(:source, :foo)
      #      add_property_translation(:source, :bar)
      #    end
      #
      #    model = MyClass.new(:source => 'some value')
      #    model.foo
      #    # => "some value"
      #    model.bar
      #    # => "some value"
      #
      #    model.foo = 'some other value'
      #    model.foo
      #    # => "some other value"
      #    model.bar
      #    # => "some value"
      #
      #    model.source = 'new value'
      #    model.foo
      #    # => "new value"
      #    model.bar
      #    # => "new value"
      #
      # @param [Symbol,String] from_name the name of the source property
      # @param [Symbol,String] to_name the name of the destination property
      def add_property_translation(from_name, to_name)
        source = from_name.to_sym
        target = to_name.to_sym

        translations[source] ||= []
        translations[source] << target
        define_writer_with_translations(source)
      end

      # A map of the configured property translations, keyed on from_name
      #
      # @return [Hash<Symbol,Array>] key is from_name, value is list of to_names
      def translations
        @translations ||= {}
      end

      private

      def define_writer_with_translations(source)
        class_eval do
          remove_method("#{source}=") if method_defined?("#{source}=")
          define_method("#{source}=") do |value|
            self.class.translations[source].each do |target|
              send("#{target}=", value)
            end
          end
        end
      end
    end
  end
end
