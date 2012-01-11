require 'spec_helper'

describe Modelish::PropertyTranslations do
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

    it { should be_a Hash }
    it { should be_empty }
  end

  describe '.add_property_translation' do
    subject { add_translation }
    let(:add_translation) { model_class.add_property_translation(from_name, to_name) }

    context 'when there are no existing translations for the property' do
      context 'with symbolic property names' do
        let(:from_name) { :my_input_prop }
        let(:to_name) { :foo_prop }

        it 'should map the input property to the output property in the translations hash' do
          expect { subject }.to change { model_class.translations[from_name] }.to([to_name])
        end

        describe "the generated model" do
          before { add_translation }

          subject { model }

          it { should respond_to(to_name) }
          it { should_not respond_to(from_name) }

          it { should respond_to("#{to_name}=") }

          let(:value) { 'blah' }

          describe "non-translated mutator" do
            subject { model.send("#{to_name}=", value) }

            it 'should change the property value' do
              expect { subject }.to change { model.send(to_name) }.from(nil).to(value)
            end
          end

          it { should respond_to("#{from_name}=") }

          describe "translated mutator" do
            subject { model.send("#{from_name}=", value) }

            it 'should change the property value' do
              expect { subject }.to change { model.send(to_name) }.from(nil).to(value)
            end
          end
        end
      end

      context 'with non-symbolic property names' do
        let(:from_name) { 'my_input_prop' }
        let(:to_name) { 'foo_prop' }

        it 'should map the symbolic input property to the symbolic output property in the translations hash' do
          expect { subject }.to change { model_class.translations[from_name.to_sym] }.from(nil).to([to_name.to_sym])
        end
      end
    end

    context 'when there is an existing translation for the property' do
      before { model_class.add_property_translation(from_name, other_to_name) }
      let(:other_to_name) { :bar_prop }
      let(:from_name) { :input_prop }
      let(:to_name) { :foo_prop }

      it 'should add output property to the mapping for the input property' do
        subject
        model_class.translations[from_name].should include(to_name)
        model_class.translations[from_name].should include(other_to_name)
      end

      describe 'generated model' do
        before { add_translation }
        subject { model }

        it { should respond_to(other_to_name) }
        it { should respond_to(to_name) }
        it { should_not respond_to(from_name) }

        it { should respond_to("#{other_to_name}=") }

        let(:value) { 'blah' }

        describe 'non-translated mutator for the existing property' do
          subject { model.send("#{other_to_name}=", value) }

          it 'should change the value for the existing property' do
            expect { subject }.to change { model.send(other_to_name) }.to(value)
          end

          it 'should not change the value for the new property' do
            expect { subject }.to_not change { model.send(to_name) }
          end
        end

        it { should respond_to("#{to_name}=") }

        describe 'non-translated mutator for the new property' do
          subject { model.send("#{to_name}=", value) }

          it 'should change the value for the new property' do
            expect { subject }.to change { model.send(to_name) }.to(value)
          end

          it 'should not change the value for the existing property' do
            expect { subject }.to_not change { model.send(other_to_name) }
          end
        end

        it { should respond_to("#{from_name}=") }

        describe 'translated mutator' do
          subject { model.send("#{from_name}=", value) }

          it 'should change the value for the existing property' do
            expect { subject }.to change { model.send(other_to_name) }.to(value)
          end

          it 'should change the value for the new property' do
            expect { subject }.to change { model.send(to_name) }.to(value)
          end
        end
      end
    end
  end
end
