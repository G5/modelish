# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Modelish::PropertyTranslations do
  let(:model_class) do
    Class.new do
      include Modelish::PropertyTranslations

      attr_accessor :foo_prop, :bar_prop
    end
  end

  let(:model) { model_class.new }

  subject { model_class }

  describe '.translations' do
    subject { model_class.translations }

    it { is_expected.to be_a Hash }
    it { is_expected.to be_empty }
  end

  describe '.add_property_translation' do
    subject(:add_translation) do
      model_class.add_property_translation(from_name, to_name)
    end

    context 'when there are no existing translations' do
      context 'with symbolic property names' do
        let(:from_name) { :my_input_prop }
        let(:to_name) { :foo_prop }

        it 'maps the input property to the output property' do
          expect { subject }.to change { model_class.translations[from_name] }
            .to([to_name])
        end

        describe 'the generated model' do
          before { add_translation }

          subject { model }

          it { is_expected.to respond_to(to_name) }
          it { is_expected.to_not respond_to(from_name) }
          it { is_expected.to respond_to("#{to_name}=") }

          let(:value) { 'blah' }

          describe 'non-translated mutator' do
            subject { model.send("#{to_name}=", value) }

            it 'changes the property value' do
              expect { subject }.to change { model.send(to_name) }
                .from(nil).to(value)
            end
          end

          it { is_expected.to respond_to("#{from_name}=") }

          describe 'translated mutator' do
            subject { model.send("#{from_name}=", value) }

            it 'changes the property value' do
              expect { subject }.to change { model.send(to_name) }
                .from(nil).to(value)
            end
          end
        end
      end

      context 'with non-symbolic property names' do
        let(:from_name) { 'my_input_prop' }
        let(:to_name) { 'foo_prop' }

        it 'maps the symbolic input property to the symbolic output property' do
          from_key = from_name.to_sym
          to_key = to_name.to_sym
          expect { subject }.to change { model_class.translations[from_key] }
            .to([to_key])
        end
      end
    end

    context 'when there is an existing translation for the property' do
      before { model_class.add_property_translation(from_name, other_to_name) }
      let(:other_to_name) { :bar_prop }
      let(:from_name) { :input_prop }
      let(:to_name) { :foo_prop }

      it 'adds output property to the mapping for the input property' do
        subject
        expect(model_class.translations[from_name]).to include(to_name,
                                                               other_to_name)
      end

      describe 'generated model' do
        before { add_translation }
        subject { model }

        it { is_expected.to respond_to(other_to_name) }
        it { is_expected.to respond_to(to_name) }
        it { is_expected.to_not respond_to(from_name) }

        it { is_expected.to respond_to("#{other_to_name}=") }

        let(:value) { 'blah' }

        describe 'non-translated mutator for the existing property' do
          subject { model.send("#{other_to_name}=", value) }

          it 'changes the value for the existing property' do
            expect { subject }.to change { model.send(other_to_name) }.to(value)
          end

          it 'does not change the value for the new property' do
            expect { subject }.to_not change { model.send(to_name) }
          end
        end

        it { is_expected.to respond_to("#{to_name}=") }

        describe 'non-translated mutator for the new property' do
          subject { model.send("#{to_name}=", value) }

          it 'changes the value for the new property' do
            expect { subject }.to change { model.send(to_name) }.to(value)
          end

          it 'does not change the value for the existing property' do
            expect { subject }.to_not change { model.send(other_to_name) }
          end
        end

        it { is_expected.to respond_to("#{from_name}=") }

        describe 'translated mutator' do
          subject { model.send("#{from_name}=", value) }

          it 'changes the value for the existing property' do
            expect { subject }.to change { model.send(other_to_name) }.to(value)
          end

          it 'changes the value for the new property' do
            expect { subject }.to change { model.send(to_name) }.to(value)
          end
        end
      end
    end
  end
end
