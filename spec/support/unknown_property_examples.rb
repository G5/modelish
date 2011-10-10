shared_examples_for 'an unknown property handler' do
  context 'when ignore_unknown_properties is set to false' do
    let(:ignore_unknown_props) { false }

    it 'should raise an error' do
      expect { subject }.to raise_error(NoMethodError)
    end
  end

  context 'when ignore_unknown_properties is set to true' do
    let(:ignore_unknown_props) { true }

    it 'should not raise an error' do
      expect { subject }.to_not raise_error
    end

    it { should_not respond_to(unknown_prop) }
  end
end
