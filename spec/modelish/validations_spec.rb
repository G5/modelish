# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Modelish::Validations do
  let(:model_class) { Class.new { include Modelish::Validations } }

  let(:property_name) { :validated_property }

  let(:model) { model_class.new }

  subject { model_class }

  it { is_expected.to respond_to(:validate_required?) }

  describe '.validate_required?' do
    subject { model_class.validate_required?(property_name => value) }

    context 'when value is nil' do
      let(:value) { nil }

      it { is_expected.to eq(false) }
    end

    context 'when value is blank' do
      let(:value) { '    ' }

      it { is_expected.to eq(false) }
    end

    context 'when value is not blank' do
      let(:value) { Object.new }

      it { is_expected.to eq(true) }
    end
  end

  it { is_expected.to respond_to(:validate_required) }

  describe '.validate_required' do
    subject { errors }
    let(:errors) { model_class.validate_required(property_name => value) }

    context 'when value is nil' do
      let(:value) { nil }

      it { is_expected.to_not be_empty }

      describe 'first error' do
        subject { errors.first }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
      end
    end

    context 'when value is blank' do
      let(:value) { '        ' }

      it { is_expected.to_not be_empty }

      describe 'first error' do
        subject { errors.first }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
      end
    end

    context 'when value is not blank' do
      let(:value) { Object.new }

      it { is_expected.to be_empty }
    end
  end

  it { is_expected.to respond_to(:validate_required!) }

  describe '.validate_required!' do
    subject { model_class.validate_required!(property_name => value) }

    context 'when value is nil' do
      let(:value) { nil }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end

      it 'includes the name in the error message' do
        expect { subject }.to raise_error do |e|
          expect(e.message).to match(/#{property_name}/i)
        end
      end
    end

    context 'when value is blank' do
      let(:value) { '           ' }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end

      it 'includes the name in the error message' do
        expect { subject }.to raise_error do |e|
          expect(e.message).to match(/#{property_name}/i)
        end
      end
    end

    context 'when value is not blank' do
      let(:value) { 'valid value' }

      it 'does not raise any errors' do
        expect { subject }.to_not raise_error
      end
    end
  end

  it { is_expected.to respond_to(:validate_length) }

  describe '.validate_length' do
    subject { model_class.validate_length(property_name, value, max_length) }
    let(:max_length) { 10 }

    context 'when value is longer than max_length' do
      let(:value) { 'a' * (max_length + 1) }

      it { is_expected.to be_an ArgumentError }
      its(:message) { is_expected.to match(/#{property_name}/i) }
      its(:message) { is_expected.to match(/#{max_length}/) }
    end

    context 'when value is shorter than max_length' do
      let(:value) { 'a' * (max_length - 1) }

      it { is_expected.to be_nil }
    end

    context 'when value is the same length as max_length' do
      let(:value) { 'a' * max_length }

      it { is_expected.to be_nil }
    end

    context 'when value is nil' do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context 'when max_length is nil' do
      let(:value) { double(length: 50) }
      let(:max_length) { nil }

      it { is_expected.to be_nil }
    end
  end

  it { is_expected.to respond_to(:validate_length?) }

  describe '.validate_length?' do
    subject { model_class.validate_length?(property_name, value, max_length) }
    let(:max_length) { 16 }

    context 'when value is longer than max_length' do
      let(:value) { 'a' * (max_length + 1) }

      it { is_expected.to eq(false) }
    end

    context 'when value is shorter than max_length' do
      let(:value) { 'a' * (max_length - 1) }

      it { is_expected.to eq(true) }
    end

    context 'when value is the same length as max_length' do
      let(:value) { 'a' * max_length }

      it { is_expected.to eq(true) }
    end

    context 'when value is nil' do
      let(:value) { nil }

      it { is_expected.to eq(true) }
    end

    context 'when max_length is nil' do
      let(:value) { Object.new }
      let(:max_length) { nil }

      it { is_expected.to eq(true) }
    end
  end

  it { is_expected.to respond_to(:validate_length!) }

  describe '.validate_length!' do
    subject { model_class.validate_length!(property_name, value, max_length) }
    let(:max_length) { 8 }

    context 'when value is longer than max_length' do
      let(:value) { 'a' * (max_length + 1) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end

      it 'includes the name in the error message' do
        expect { subject }.to raise_error do |e|
          expect(e.message).to match(/#{property_name}/i)
        end
      end

      it 'includes the max length in the error message' do
        expect { subject }.to raise_error do |e|
          expect(e.message).to match(/#{max_length}/)
        end
      end
    end

    context 'when value is shorter than max_length' do
      let(:value) { 'a' * (max_length - 1) }

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when value is nil' do
      let(:value) { nil }

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when max_length is nil' do
      let(:max_length) { nil }
      let(:value) { 'aaaaaaaaaaa' }

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end
  end

  it { is_expected.to respond_to(:validate_type) }

  describe '.validate_type' do
    subject do
      model_class.validate_type(property_name, property_value, property_type)
    end

    context 'for type Integer' do
      let(:property_type) { Integer }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end

      context 'with valid int' do
        let(:property_value) { 42 }

        it { is_expected.to be_nil }
      end

      context 'with valid string' do
        let(:property_value) { '42' }

        it { is_expected.to be_nil }
      end

      context 'with invalid value' do
        let(:property_value) { 42.99 }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value.inspect}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'for type Float' do
      let(:property_type) { Float }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end

      context 'with valid float value' do
        let(:property_value) { 42.5 }

        it { is_expected.to be_nil }
      end

      context 'with valid string' do
        let(:property_value) { '42.5' }

        it { is_expected.to be_nil }
      end

      context 'with valid type that can be upcast' do
        let(:property_value) { 42 }

        it { is_expected.to be_nil }
      end

      context 'with invalid value' do
        let(:property_value) { 'forty-two' }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value.inspect}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'for type Array' do
      let(:property_type) { Array }

      context 'with nil' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end
      context 'with a valid array' do
        let(:property_value) { [1, 2, 3] }

        it { is_expected.to be_nil }
      end

      context 'with an invalid value' do
        let(:property_value) { { 1 => 2, 3 => 4 } }
        let(:property_value_regex) do
          property_value.inspect.gsub('{', '\{').gsub('}', '\}')
        end

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value_regex}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'for an arbitrary class' do
      let(:property_type) { Hash }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end

      context 'with valid hash value' do
        let(:property_value) { { 1 => 2 } }

        it { is_expected.to be_nil }
      end

      context 'with invalid value' do
        let(:property_value) { [1, 2] }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value.inspect}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'for type Date' do
      let(:property_type) { Date }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end

      context 'with valid string' do
        let(:property_value) { '2011-03-10' }

        it { is_expected.to be_nil }
      end

      context 'with valid Date' do
        let(:property_value) { Date.civil(2011, 3, 10) }

        it { is_expected.to be_nil }
      end

      context 'with invalid value' do
        let(:property_value) { 'this is not a date' }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value.inspect}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'for type DateTime' do
      let(:property_type) { DateTime }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end

      context 'with valid string' do
        let(:property_value) { '2011-03-10T03:15:23-05:00' }

        it { is_expected.to be_nil }
      end

      context 'with valid DateTime' do
        let(:property_value) do
          DateTime.civil(2011, 3, 10, 3, 15, 23, Rational(-5, 24))
        end

        it { is_expected.to be_nil }
      end

      context 'with invalid value' do
        let(:property_value) { 'this is not a date time' }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value.inspect}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'for a Symbol type' do
      let(:property_type) { Symbol }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to be_nil }
      end

      context 'with a valid string' do
        let(:property_value) { 'my string' }

        it { is_expected.to be_nil }
      end

      context 'with a valid symbol' do
        let(:property_value) { :my_symbol }

        it { is_expected.to be_nil }
      end

      context 'with an invalid value' do
        let(:property_value) { Object.new }

        it { is_expected.to be_an ArgumentError }
        its(:message) { is_expected.to match(/#{property_name}/i) }
        its(:message) { is_expected.to match(/#{property_value.inspect}/i) }
        its(:message) { is_expected.to match(/#{property_type}/i) }
      end
    end

    context 'when type is nil' do
      let(:property_type) { nil }

      context 'with any value' do
        let(:property_value) { 'foo' }

        it { is_expected.to be_nil }
      end
    end
  end

  it { is_expected.to respond_to(:validate_type!) }

  describe '.validate_type!' do
    subject do
      model_class.validate_type!(property_name, property_value, property_type)
    end

    context 'for type Integer' do
      let(:property_type) { Integer }

      context 'with nil value' do
        let(:property_value) { nil }

        it 'does not raise any errors' do
          expect { subject }.to_not raise_error
        end
      end

      context 'with valid int' do
        let(:property_value) { 42 }

        it 'does not raise any errors' do
          expect { subject }.to_not raise_error
        end
      end

      context 'with valid string' do
        let(:property_value) { '42' }

        it 'does not raise any errors' do
          expect { subject }.to_not raise_error
        end
      end

      context 'with invalid value' do
        let(:property_value) { 42.99 }

        it 'raises an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end

        it 'references the property name in the error message' do
          expect { subject }.to raise_error do |e|
            expect(e.message).to match(/#{property_name}/i)
          end
        end
      end
    end
  end

  it { is_expected.to respond_to(:validate_type?) }

  describe '.validate_type?' do
    subject do
      model_class.validate_type?(property_name, property_value, property_type)
    end

    context 'for type Integer' do
      let(:property_type) { Integer }

      context 'with nil value' do
        let(:property_value) { nil }

        it { is_expected.to eq(true) }
      end

      context 'with valid int' do
        let(:property_value) { 42 }

        it { is_expected.to eq(true) }
      end

      context 'with valid string' do
        let(:property_value) { '42' }

        it { is_expected.to eq(true) }
      end

      context 'with invalid value' do
        let(:property_value) { 42.99 }

        it { is_expected.to eq(false) }
      end
    end
  end

  it { is_expected.to respond_to(:add_validator) }

  context 'with simple validated property' do
    before do
      model_class.add_validator(property_name, &validator_block)
      model.send("#{property_name}=", property_value)
    end

    subject { model }

    let(:property_value) { '42' }

    let(:message_validator) do
      ->(val) { val.to_i != 42 ? "#{property_name} must be 42" : nil }
    end

    let(:error_validator) do
      lambda do |val|
        val.to_i != 42 ? ArgumentError.new("#{property_name} must be 42") : nil
      end
    end

    describe '.validators' do
      let(:validator_block) { message_validator }

      subject { validators }
      let(:validators) { model_class.validators }

      its(:size) { is_expected.to eq(1) }

      describe '[property_name]' do
        subject { prop_validators }
        let(:prop_validators) { validators[property_name] }

        its(:size) { is_expected.to eq(1) }

        describe '#first' do
          subject { prop_validators.first }

          it { is_expected.to respond_to(:call) }
          it { is_expected.to eq(validator_block) }
        end
      end
    end

    context 'with valid value' do
      context 'with validator that returns an error message' do
        let(:validator_block) { message_validator }

        it_behaves_like 'a valid model'
      end

      context 'with validator that returns an error' do
        let(:validator_block) { error_validator }

        it_behaves_like 'a valid model'
      end
    end

    context 'with invalid value' do
      let(:property_value) { 'not valid' }

      context 'with validator that returns an error message' do
        let(:validator_block) { message_validator }

        it_behaves_like 'a model with an invalid property' do
          let(:error_count) { 1 }
        end
      end

      context 'with validator that returns an error' do
        let(:validator_block) { error_validator }

        it_behaves_like 'a model with an invalid property' do
          let(:error_count) { 1 }
        end
      end
    end
  end

  context 'with property that has multiple validations' do
    before do
      model_class.add_validator(property_name, &nil_validator)
      model_class.add_validator(property_name, &int_validator)
      model.send("#{property_name}=", property_value)
    end

    subject { model }

    let(:nil_validator) do
      lambda do |val|
        val.nil? ? "#{property_name} is_expected.to not be nil" : nil
      end
    end
    let(:int_validator) do
      lambda do |val|
        "#{property_name} must represent the integer 42" unless val.to_i == 42
      end
    end

    let(:property_value) { '42' }

    describe '.validators' do
      subject { validators }
      let(:validators) { model_class.validators }

      its(:size) { is_expected.to eq(1) }

      describe '[property_name]' do
        subject { prop_validators }
        let(:prop_validators) { validators[property_name] }

        its(:size) { is_expected.to eq(2) }

        describe '#first' do
          subject { prop_validators.first }
          it { is_expected.to respond_to(:call) }
          it { is_expected.to eq(nil_validator) }
        end

        describe '#last' do
          subject { prop_validators.last }
          it { is_expected.to respond_to(:call) }
          it { is_expected.to eq(int_validator) }
        end
      end
    end

    context 'with valid value' do
      it { is_expected.to be_valid }

      describe '#validate' do
        subject { model.validate }

        it { is_expected.to be_empty }
      end

      describe '#validate!' do
        subject { model.validate! }

        it 'does not raise any errors' do
          expect { subject }.to_not raise_error
        end
      end
    end

    context 'with nil value' do
      let(:property_value) { nil }

      it { is_expected.to_not be_valid }

      describe '#validate' do
        subject { errors }
        let(:errors) { model.validate }

        its(:size) { is_expected.to eq(1) }

        it { is_expected.to have_key(property_name) }

        describe '[property_name]' do
          subject { prop_errors }
          let(:prop_errors) { errors[property_name] }

          its(:size) { is_expected.to eq(2) }

          describe '#first' do
            subject { prop_errors.first }

            it { is_expected.to be_a ArgumentError }
            its(:message) { is_expected.to match(/#{property_name}/i) }
            its(:message) { is_expected.to match(/nil/i) }
          end

          describe '#last' do
            subject { prop_errors.last }

            it { is_expected.to be_a ArgumentError }
            its(:message) { is_expected.to match(/#{property_name}/i) }
            its(:message) { is_expected.to match(/integer/i) }
          end
        end
      end

      describe '#validate!' do
        subject { model.validate! }

        it 'raises an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end

        it 'references the property name in the error message' do
          expect { subject }.to raise_error do |e|
            expect(e.message).to match(/#{property_name}/i)
          end
        end
      end
    end
  end
end
