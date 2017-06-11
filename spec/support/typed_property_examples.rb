# frozen_string_literal: true

# Assume the following are defined:
# model - the model on which the property is defined
# valid_string - a string with a valid value for the property
# valid_typed_value - instance of property_type that is valid for the property
# invalid_value - an object that cannot be translated to the property type
# default_value - the default value for the property
# error_type - defaults to ArgumentError
RSpec.shared_examples_for 'a typed property' do |prop_name, prop_type|
  accessor = prop_name.to_sym
  raw_accessor = "raw_#{prop_name}".to_sym
  bang_accessor = "#{prop_name}!".to_sym
  mutator = "#{prop_name}=".to_sym

  subject { model }

  let(:error_type) { ArgumentError }

  it { is_expected.to respond_to(accessor) }
  its(prop_name) { is_expected.to eq(default_value) }

  it { is_expected.to respond_to(raw_accessor) }
  its(raw_accessor) { is_expected.to eq(default_value) }

  it { is_expected.to respond_to(bang_accessor) }
  its(bang_accessor) { is_expected.to eq(default_value) }

  it { is_expected.to respond_to(mutator) }

  describe 'property_type mapping' do
    subject { model.class.property_types }

    it { is_expected.to be }
    it { is_expected.to have_key(prop_name) }

    if prop_type
      its([prop_name]) { is_expected.to eq(prop_type) }
    else
      its([prop_name]) { is_expected.to be_a Proc }
    end
  end

  describe 'assignment' do
    before { model.send(mutator, property_value) }

    context 'with nil' do
      let(:property_value) { nil }

      its(accessor) { is_expected.to be_nil }
      its(raw_accessor) { is_expected.to be_nil }

      it 'does not raise an error when the bang accessor is invoked' do
        expect { subject.send(bang_accessor) }.to_not raise_error
      end

      its(bang_accessor) { is_expected.to be_nil }
    end

    context 'with valid string' do
      let(:property_value) { valid_string }

      its(accessor) { is_expected.to eq(valid_typed_value) }
      its(raw_accessor) { is_expected.to eq(property_value) }

      it 'does not raise an error when the bang accessor is invoked' do
        expect { subject.send(bang_accessor) }.to_not raise_error
      end

      its(bang_accessor) { is_expected.to eq(valid_typed_value) }
    end

    context 'with valid typed value' do
      let(:property_value) { valid_typed_value }

      its(accessor) { is_expected.to eq(property_value) }
      its(raw_accessor) { is_expected.to eq(property_value) }

      it 'does not raise an error when the bang accessor is invoked' do
        expect { subject.send(bang_accessor) }.to_not raise_error
      end

      its(bang_accessor) { is_expected.to eq(valid_typed_value) }
    end

    unless [String, Array, Symbol].include?(prop_type)
      context 'with a value that cannot be converted' do
        let(:property_value) { invalid_value }

        its(accessor) { is_expected.to eq(property_value) }
        its(raw_accessor) { is_expected.to eq(property_value) }

        it 'raises an error when the bang accessor is invoked' do
          expect { subject.send(bang_accessor) }.to raise_error(error_type)
        end
      end
    end
  end
end
