# Assumes that let(:model) has been defined
shared_examples_for 'a valid model' do
  subject { model }

  it { should be_valid }

  it { should respond_to(:validate) }

  describe "validate" do
    subject { model.validate }

    it { should be_empty }
  end

  it { should respond_to(:validate!) }

  describe "validate!" do
    subject { model.validate! }

    it "should not raise any errors" do
      expect { subject }.to_not raise_error
    end
  end
end

# Assumes the following let statements have been defined
# model - the model on which the property has been defined
# property_name - the name of the property that is invalid
# error_count - the number of expected errors on the property
shared_examples_for 'a model with an invalid property' do
  subject { model }

  it { should_not be_valid }

  it { should respond_to(:validate) }

  describe "validate" do
    subject { errors }
    let(:errors) { model.validate }

    it { should have_key(property_name) }

    describe "[property_name]" do
      subject { prop_errors }
      let(:prop_errors) { errors[property_name] }

      its(:size) { is_expected.to eq(error_count) }

      it "should be a collection of ArgumentErrors" do
        prop_errors.each { |p| p.should be_an ArgumentError }
      end

      it "should reference the property name in the error message(s)" do
        prop_errors.each { |p| p.message.should match(/#{property_name}/i) }
      end
    end
  end

  describe "validate!" do
    subject { model.validate! }

    it "should raise an ArgumentError" do
      expect { subject }.to raise_error(ArgumentError)
    end

    it "should reference the property name in the error message" do
      expect { subject }.to raise_error { |e| e.message.should match(/#{property_name}/i) }
    end
  end
end
