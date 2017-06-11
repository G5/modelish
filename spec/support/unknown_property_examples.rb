# frozen_string_literal: true

RSpec.shared_examples_for 'an unknown property handler' do
  context 'when ignore_unknown_properties is set to false' do
    let(:ignore_unknown_props) { false }

    it 'raises an error' do
      expect { subject }.to raise_error(NoMethodError)
    end
  end

  context 'when ignore_unknown_properties is set to true' do
    let(:ignore_unknown_props) { true }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end

    it { is_expected.to_not respond_to(unknown_prop) }
  end
end
