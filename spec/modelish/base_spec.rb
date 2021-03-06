# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Modelish::Base do
  subject { model_class }
  let(:model_class) { Class.new(Modelish::Base) }

  let(:model) { model_class.new(init_options) }
  let(:init_options) { nil }
  let(:default_value) { nil }

  it { is_expected.to respond_to(:property) }

  context 'without any properties' do
    subject { model }

    context 'when the model is initialized with an unknown property' do
      let(:init_options) { { unknown_prop => 'whatever' } }
      let(:unknown_prop) { :foo }

      context 'when class ignore_unknown_properties is set' do
        before { model_class.ignore_unknown_properties = ignore_unknown_props }
        after { model_class.reset }

        it_behaves_like 'an unknown property handler'
      end

      context 'when global ignore_unknown_properties is set' do
        before do
          Modelish.configure do |config|
            config.ignore_unknown_properties = ignore_unknown_props
          end
        end
        after { Modelish.reset }

        it_behaves_like 'an unknown property handler'

        context 'when class and global ignore_unknown_properties are set' do
          before do
            Modelish.configure do |config|
              config.ignore_unknown_properties = !ignore_unknown_props
            end
          end
          after { Modelish.reset }

          before do
            model_class.ignore_unknown_properties = ignore_unknown_props
          end
          after { model_class.reset }

          it_behaves_like 'an unknown property handler'
        end
      end

      context 'when ignore_unknown_properties has not been configured' do
        it 'raises an error' do
          expect { subject }.to raise_error(NoMethodError)
        end
      end
    end

    describe '#to_hash' do
      subject { model.to_hash }
      it { is_expected.to be_empty }
    end
  end

  context 'with simple property' do
    before { model_class.property(property_name) }

    let(:property_name) { :simple_property }
    let(:property_value) { 'simple string value' }

    it_behaves_like 'a modelish property'
    it_behaves_like 'a valid model'

    describe '#to_hash' do
      let(:init_options) { { property_name => property_value } }
      subject { model.to_hash }

      its(:size) { is_expected.to eq(1) }
      it { is_expected.to have_key(property_name.to_s) }
      its(['simple_property']) { is_expected.to eq(property_value) }
    end
  end

  context 'with property default value' do
    before { model_class.property(property_name, default: default_value) }

    let(:property_name) { :default_property }
    let(:property_value) { 'non-default value' }
    let(:default_value) { 42 }

    it_behaves_like 'a modelish property'
    it_behaves_like 'a valid model'

    describe '#to_hash' do
      subject { model.to_hash }

      context 'with default value' do
        its(:size) { is_expected.to eq(1) }
        it { is_expected.to have_key(property_name.to_s) }
        its(['default_property']) { is_expected.to eq(default_value) }
      end

      context 'without default value' do
        let(:init_options) { { property_name => property_value } }

        its(:size) { is_expected.to eq(1) }
        it { is_expected.to have_key(property_name.to_s) }
        its(['default_property']) { is_expected.to eq(property_value) }
      end
    end
  end

  context 'with translated property' do
    before { model_class.property(to_name, from: from_name) }

    let(:to_name) { :translated_property }
    let(:from_name) { 'OldPropertyNAME' }
    let(:property_value) { 'new value' }

    subject { model }

    context 'when there is one translation for the source property' do
      it_behaves_like 'a modelish property' do
        let(:property_name) { to_name }
      end

      it { is_expected.to_not respond_to(from_name) }
      it { is_expected.to respond_to("#{from_name}=") }

      describe 'translated mutator' do
        subject { model.send("#{from_name}=", property_value) }

        it 'changes the property value' do
          expect { subject }.to change { model.send(to_name) }
            .from(nil).to(property_value)
        end
      end

      it_behaves_like 'a valid model'

      describe '#to_hash' do
        subject { model.to_hash }

        context 'when set from untranslated property name' do
          let(:init_options) { { to_name => property_value } }

          its(:size) { is_expected.to eq(1) }
          it { is_expected.to have_key(to_name.to_s) }
          its(['translated_property']) { is_expected.to eq(property_value) }
        end

        context 'when set from the translation' do
          let(:init_options) { { from_name => property_value } }

          its(:size) { is_expected.to eq(1) }
          it { is_expected.to have_key(to_name.to_s) }
          its(['translated_property']) { is_expected.to eq(property_value) }
        end
      end
    end

    context 'when there are multiple translations for the source property' do
      before { model_class.property(other_to_name, from: from_name) }
      let(:other_to_name) { :my_other_prop }

      it_behaves_like 'a modelish property' do
        let(:property_name) { other_to_name }
      end

      it_behaves_like 'a modelish property' do
        let(:property_name) { to_name }
      end

      it_behaves_like 'a valid model'

      it { is_expected.to_not respond_to(from_name) }
      it { is_expected.to respond_to("#{from_name}=") }

      describe 'translated mutator' do
        subject { model.send("#{from_name}=", property_value) }

        it 'changes the value of the first property' do
          expect { subject }.to change { model.send(to_name) }
            .from(nil).to(property_value)
        end

        it 'changes the value of the other property' do
          expect { subject }.to change { model.send(other_to_name) }
            .from(nil).to(property_value)
        end
      end

      describe '#to_hash' do
        subject { model.to_hash }

        context 'when initialized with first property' do
          let(:init_options) { { to_name => property_value } }

          its(:size) { is_expected.to eq(2) }

          it { is_expected.to have_key(to_name.to_s) }
          its(['translated_property']) { is_expected.to eq(property_value) }

          it { is_expected.to have_key(other_to_name.to_s) }
          its(['my_other_prop']) { is_expected.to be_nil }
        end

        context 'when initialized with second property' do
          let(:init_options) { { other_to_name => property_value } }

          its(:size) { is_expected.to eq(2) }

          it { is_expected.to have_key(to_name.to_s) }
          its(['translated_property']) { is_expected.to be_nil }

          it { is_expected.to have_key(other_to_name.to_s) }
          its(['my_other_prop']) { is_expected.to eq(property_value) }
        end

        context 'when initialized with translated property' do
          let(:init_options) { { from_name => property_value } }

          context 'when there are no individual property initializations' do
            its(:size) { is_expected.to eq(2) }

            it { is_expected.to have_key(to_name.to_s) }
            its(['translated_property']) { is_expected.to eq(property_value) }

            it { is_expected.to have_key(other_to_name.to_s) }
            its(['my_other_prop']) { is_expected.to eq(property_value) }
          end

          context 'when the destination property is initialized' do
            before { init_options[to_name] = other_value }
            let(:other_value) { 'and now for something completely different' }

            its(:size) { is_expected.to eq(2) }

            it { is_expected.to have_key(to_name.to_s) }
            its(['translated_property']) { is_expected.to eq(other_value) }

            it { is_expected.to have_key(other_to_name.to_s) }
            its(['my_other_prop']) { is_expected.to eq(property_value) }
          end
        end
      end
    end
  end

  context 'with typed property' do
    before { model_class.property(property_name, options) }

    subject { model }

    let(:property_name) { :my_int_property }
    let(:property_type) { Integer }

    let(:valid_string) { '42' }
    let(:valid_typed_value) { 42 }
    let(:invalid_value) { '42.0' }

    context 'without default value' do
      let(:options) { { type: property_type } }
      let(:default_value) { nil }

      context 'without init options' do
        it_behaves_like 'a typed property', :my_int_property, Integer
        it_behaves_like 'a valid model'

        describe '#to_hash' do
          subject { model.to_hash }

          its(:size) { is_expected.to eq(1) }
          it { is_expected.to have_key(property_name.to_s) }
          its(['my_int_property']) { is_expected.to be_nil }
        end
      end

      context 'with init options' do
        let(:model) { model_class.new(property_name => valid_string) }

        its(:my_int_property) { is_expected.to eq(valid_typed_value) }
        its(:raw_my_int_property) { is_expected.to eq(valid_string) }

        it_behaves_like 'a valid model'

        describe '#to_hash' do
          subject { model.to_hash }

          its(:size) { is_expected.to eq(1) }
          it { is_expected.to have_key(property_name.to_s) }
          its(['my_int_property']) { is_expected.to eq(valid_typed_value) }
        end
      end
    end

    context 'with default value' do
      let(:options) { { type: property_type, default: default_value } }
      let(:default_value) { 0 }

      it_behaves_like 'a typed property', :my_int_property, Integer

      it_behaves_like 'a valid model'

      describe '#to_hash' do
        subject { model.to_hash }

        its(:size) { is_expected.to eq(1) }
        it { is_expected.to have_key(property_name.to_s) }
        its(['my_int_property']) { is_expected.to eq(default_value) }
      end
    end
  end

  context 'with required property' do
    before { model_class.property(property_name, required: true) }

    let(:property_name) { :my_required_property }
    let(:property_value) { 'a valid string' }

    subject { model }

    let(:init_options) { { property_name => property_value } }

    it_behaves_like 'a modelish property'

    context 'when property value is not nil' do
      it_behaves_like 'a valid model'
    end

    context 'when property value is nil' do
      let(:property_value) { nil }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end

    context 'when property value is an empty string' do
      let(:property_value) { '          ' }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end
  end

  context 'with length-restricted property' do
    before do
      model_class.property(property_name, required: false,
                                          max_length: max_length)
    end

    let(:property_name) { :my_required_property }
    let(:property_value) { 'a' * (max_length - 1) }
    let(:max_length) { 10 }

    subject { model }

    let(:init_options) { { property_name => property_value } }

    it_behaves_like 'a modelish property'

    context 'when property value is nil' do
      let(:property_value) { nil }

      it_behaves_like 'a valid model'
    end

    context 'when property value is a valid string' do
      it_behaves_like 'a valid model'
    end

    context 'when property value is too long' do
      let(:property_value) { 'a' * (max_length + 1) }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end
  end

  context 'with property that has validator block' do
    before do
      model_class.property(property_name, validator: validator_block)
    end

    let(:property_name) { :validated_property }
    let(:validator_block) do
      lambda do |val|
        "#{property_name} must support to_hash" unless val.respond_to?(:to_hash)
      end
    end
    let(:property_value) { {} }

    subject { model }

    let(:init_options) { { property_name => property_value } }

    it_behaves_like 'a modelish property'

    context 'when value is valid' do
      it_behaves_like 'a valid model'
    end

    context 'when value is invalid' do
      let(:property_value) { [] }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end
  end

  context 'with type-validated property' do
    before { model_class.property(property_name, prop_options) }

    let(:prop_options) { { type: Integer, validate_type: true } }
    let(:property_name) { :strict_typed_property }
    let(:property_value) { 42 }

    subject { model }

    let(:init_options) { { property_name => property_value } }

    it_behaves_like 'a modelish property'

    context 'when value is nil' do
      let(:property_value) { nil }

      it_behaves_like 'a valid model'
    end

    context 'when value is valid' do
      let(:property_value) { '42' }

      it_behaves_like 'a valid model'
    end

    context 'when value is invalid' do
      let(:property_value) { 'forty-two' }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end

    context 'with no property type' do
      let(:prop_options) { { validate_type: true } }

      context 'when value is nil' do
        let(:property_value) { nil }

        it_behaves_like 'a valid model'
      end

      context 'when value is not nil' do
        let(:property_value) { Object.new }

        it_behaves_like 'a valid model'
      end
    end
  end

  context 'with multiple validations' do
    before do
      model_class.property(property_name, required: true,
                                          max_length: 3,
                                          type: Symbol,
                                          validate_type: true)
    end

    let(:init_options) { { property_name => property_value } }

    let(:property_name) { :prop_with_many_validations }

    context 'when value is valid' do
      let(:property_value) { :foo }

      it_behaves_like 'a valid model'
    end

    context 'when value is nil' do
      let(:property_value) { nil }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end

    context 'when value is too long' do
      let(:property_value) { :crazy_long_value }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end

    context 'when value is not a symbol' do
      let(:property_value) { Object.new }

      it_behaves_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end
  end
end
