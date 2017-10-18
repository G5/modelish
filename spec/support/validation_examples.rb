# frozen_string_literal: true

# Assumes that let(:model) has been defined
RSpec.shared_examples_for 'a valid model' do
  subject { model }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:validate) }

  describe '#validate' do
    subject { model.validate }

    it { is_expected.to be_empty }
  end

  it { is_expected.to respond_to(:validate!) }

  describe '#validate!' do
    subject { model.validate! }

    it 'does not raise any errors' do
      expect { subject }.to_not raise_error
    end
  end
end

# Assumes the following let statements have been defined
# model - the model on which the property has been defined
# property_name - the name of the property that is invalid
# error_count - the number of expected errors on the property
RSpec.shared_examples_for 'a model with an invalid property' do
  subject { model }

  it { is_expected.to_not be_valid }

  it { is_expected.to respond_to(:validate) }

  describe '#validate' do
    subject { errors }
    let(:errors) { model.validate }

    it { is_expected.to have_key(property_name) }

    describe '[property_name]' do
      subject { prop_errors }
      let(:prop_errors) { errors[property_name] }

      its(:size) { is_expected.to eq(error_count) }

      it 'is a collection of ArgumentErrors' do
        prop_errors.each { |p| expect(p).to be_an ArgumentError }
      end

      it 'references the property name in the error message(s)' do
        prop_errors.each do |p|
          expect(p.message).to match(/#{property_name}/i)
        end
      end
    end
  end

  describe '#validate!' do
    subject { model.validate! }

    it 'raise an ArgumentError' do
      expect { subject }.to raise_error(ArgumentError)
    end

    it 'references the property name in the error message' do
      expect { subject }.to raise_error do |e|
        expect(e.message).to match(/#{property_name}/i)
      end
    end
  end
end
