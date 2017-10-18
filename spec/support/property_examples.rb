# frozen_string_literal: true

# Assumes the following have been defined
# let(:model) -- with a model initializer that calls init_options
# let(:property_name)
# let(:property_value)
# let(:default_value)
RSpec.shared_examples_for 'a modelish property' do
  subject { model }

  let(:init_options) { { property_name => property_value } }

  context 'when initialized with symbol key' do
    let(:init_options) { { property_name.to_sym => property_value } }

    it { is_expected.to respond_to(property_name) }
  end

  context 'when initialized with a string key' do
    let(:init_options) { { property_name.to_s => property_value } }

    it { is_expected.to respond_to(property_name) }
  end

  describe 'getter' do
    subject { model.send(property_name) }

    context 'without init options' do
      let(:init_options) {}

      it { is_expected.to eq(default_value) }
    end

    context 'with symbol init options' do
      let(:init_options) { { property_name.to_sym => property_value } }

      it { is_expected.to eq(property_value) }
    end

    context 'with string init options' do
      let(:init_options) { { property_name.to_s => property_value } }

      it { is_expected.to eq(property_value) }
    end
  end

  it { is_expected.to respond_to("#{property_name}=".to_sym) }

  describe 'setter' do
    subject { model.send("#{property_name}=", new_property_value) }

    let(:new_property_value) { 'a new value' }

    it 'changes the property value' do
      expect { subject }.to change { model.send(property_name) }
        .from(property_value).to(new_property_value)
    end
  end
end
