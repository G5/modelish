module Modelish
  # Mixin behavior for mapping one property name to another
  module PropertyTranslations
    def self.included(base)
      base.extend(ClassMethods)
    end

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
        self.translations[from_name.to_sym] ||= []
        self.translations[from_name.to_sym] << to_name.to_sym

        class_eval do
          define_method("#{from_name}=") do |value|
            self.class.translations[from_name.to_sym].each do |prop|
              self.send("#{prop}=", value)
            end
          end
        end
      end

      # A map of the translations that have already been configured, keyed on from_name.
      #
      # @return [Hash<Symbol,Array>] the key is the from_name, the value is an array to_names
      def translations
        @translations ||= {}
      end
    end
  end
end
