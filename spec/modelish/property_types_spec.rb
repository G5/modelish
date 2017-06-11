# frozen_string_literal: true

require 'spec_helper'

describe Modelish::PropertyTypes do
  let(:model_class) { Class.new { include Modelish::PropertyTypes } }
  let(:model) { model_class.new }

  let(:property_name) { :my_property }

  subject { model_class }

  context 'when included' do
    it { is_expected.to respond_to(:add_property_type) }
    it { is_expected.to respond_to(:property_types) }

    describe 'property_types' do
      subject { model_class.property_types }

      it { is_expected.to be_a Hash }
      it { is_expected.to be_empty }
    end
  end

  describe '#add_property_type' do
    before { model_class.add_property_type(property_name, property_type) }

    let(:default_value) { nil }

    context 'when property_type is Integer' do
      let(:property_type) { Integer }

      it_behaves_like 'a typed property', :my_property, Integer do
        let(:valid_string) { '42' }
        let(:valid_typed_value) { 42 }
        let(:invalid_value) { 'forty-two' }
      end
    end

    context 'when property_type is Float' do
      let(:property_type) { Float }

      it_behaves_like 'a typed property', :my_property, Float do
        let(:valid_string) { '42.5' }
        let(:valid_typed_value) { 42.5 }
        let(:invalid_value) { 'forty-two point five' }
      end
    end

    context 'when property_type is Date' do
      let(:property_type) { Date }

      it_behaves_like 'a typed property', :my_property, Date do
        let(:valid_string) { '2011-03-10' }
        let(:valid_typed_value) { Date.civil(2011, 3, 10) }
        let(:invalid_value) { 'foo' }
      end
    end

    context 'when property_type is DateTime' do
      let(:property_type) { DateTime }

      it_behaves_like 'a typed property', :my_property, DateTime do
        let(:valid_string) { '2011-02-24T14:09:43-07:00' }
        let(:valid_typed_value) do
          DateTime.civil(2011, 2, 24, 14, 9, 43, Rational(-7, 24))
        end
        let(:invalid_value) { 'foo' }
      end
    end

    context 'when property_type is String' do
      let(:property_type) { String }

      it_behaves_like 'a typed property', :my_property, String do
        let(:valid_string) { "\tmy_string  \n" }
        let(:valid_typed_value) { 'my_string' }
      end
    end

    context 'when property_type is Symbol' do
      let(:property_type) { Symbol }

      it_behaves_like 'a typed property', :my_property, Symbol do
        let(:valid_string) { 'MyCrazy    String' }
        let(:valid_typed_value) { :my_crazy_string }
      end
    end

    context 'when property_type is Array' do
      let(:property_type) { Array }

      it_behaves_like 'a typed property', :my_property, Array do
        let(:valid_string) { 'my valid string' }
        let(:valid_typed_value) { ['my valid string'] }
      end
    end

    context 'when type is an arbitrary class' do
      class CustomType
        attr_accessor :foo

        def initialize(raw_val)
          if raw_val.respond_to?(:foo)
            self.foo = raw_val.foo
          elsif raw_val.is_a?(String)
            self.foo = raw_val
          else
            raise TypeError
          end
        end

        def ==(other)
          other.respond_to?(:foo) && other.foo == foo
        end
      end

      let(:property_type) { CustomType }

      it_behaves_like 'a typed property', :my_property, CustomType do
        let(:valid_string) { 'bar' }
        let(:valid_typed_value) { CustomType.new(valid_string) }
        let(:invalid_value) { Object.new }
        let(:error_type) { TypeError }
      end
    end

    context 'when type is a closure' do
      let(:property_type) do
        lambda do |val|
          value = val.respond_to?(:split) ? val.split(',') : val
          value.map(&:to_i)
        end
      end

      it_behaves_like 'a typed property', :my_property do
        let(:valid_string) { '1,2,3' }
        let(:valid_typed_value) { [1, 2, 3] }
        let(:invalid_value) { Object.new }
        let(:error_type) { NoMethodError }
      end
    end

    context 'when a property is defined more than once' do
      before do
        model_class.add_property_type(property_name, other_property_type)
      end

      let(:property_type) { Integer }

      context 'with the same property_type' do
        let(:other_property_type) { property_type }

        it 'does not raise an error when the property is accessed' do
          expect { model.send(property_name) }.to_not raise_error
        end

        it_behaves_like 'a typed property', :my_property, Integer do
          let(:valid_string) { '112358' }
          let(:valid_typed_value) { 112_358 }
          let(:invalid_value) { 'blah' }
        end
      end

      context 'with different property_types' do
        let(:other_property_type) { Float }

        it 'does not raise an error when the property is accessed' do
          expect { model.send(property_name) }.to_not raise_error
        end

        it_behaves_like 'a typed property', :my_property, Float do
          let(:valid_string) { '112358.13' }
          let(:valid_typed_value) { 112_358.13 }
          let(:invalid_value) { 'blah' }
        end
      end
    end
  end
end
