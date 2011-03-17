require 'spec_helper'

describe Modelish::Validations do
  let(:model_class) { Class.new { include Modelish::Validations } }

  let(:property_name) { :validated_property }

  let(:model) { model_class.new }

  subject { model_class }

  it { should respond_to(:validate_required?) }

  describe ".validate_required?" do
    subject { model_class.validate_required?(property_name => value) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_false }
    end

    context "when value is blank" do
      let(:value) { '    ' }

      it { should be_false }
    end

    context "when value is not blank" do
      let(:value) { Object.new }

      it { should be_true }
    end
  end

  it { should respond_to(:validate_required) }

  describe ".validate_required" do
    subject { errors }
    let(:errors) { model_class.validate_required(property_name => value) }

    context "when value is nil" do
      let(:value) { nil }

      it { should_not be_empty }

      describe "first error" do
        subject { errors.first }

        it { should be_an ArgumentError }
        its(:message) { should match(/#{property_name}/i) }
      end
    end

    context "when value is blank" do
      let(:value) { '        ' }

      it { should_not be_empty }

      describe "first error" do
        subject { errors.first }

        it { should be_an ArgumentError }
        its(:message) { should match(/#{property_name}/i) }
      end
    end

    context "when value is not blank" do
      let(:value) { Object.new }

      it { should be_empty }
    end
  end

  it { should respond_to(:validate_required!) }

  describe ".validate_required!" do  
    subject { model_class.validate_required!(property_name => value) }

    context "when value is nil" do
      let(:value) { nil }

      it "should raise an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end

      it "should include the name in the error message" do
        expect { subject }.to raise_error { |e| e.message.should match(/#{property_name}/i) }
      end
    end

    context "when value is blank" do
      let(:value) { '           ' }

      it "should raise an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end

      it "should include the name in the error message" do
        expect { subject }.to raise_error { |e| e.message.should match(/#{property_name}/i) }
      end
    end

    context "when value is not blank" do
      let(:value) { 'valid value' }

      it "should not raise any errors" do
        expect { subject }.to_not raise_error
      end
    end
  end

  it { should respond_to(:validate_length) }

  describe ".validate_length" do
    subject { model_class.validate_length(property_name, value, max_length) }
    let(:max_length) { 10 }

    context "when value is longer than max_length" do
      let(:value) { 'a' * (max_length + 1) }

      it { should be_an ArgumentError }
      its(:message) { should match(/#{property_name}/i) }
      its(:message) { should match(/#{max_length}/) }
    end

    context "when value is shorter than max_length" do
      let(:value) { 'a' * (max_length - 1) }

      it { should be_nil }
    end

    context "when value is the same length as max_length" do
      let(:value) { 'a' * max_length }

      it { should be_nil }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end

    context "when max_length is nil" do
      let(:value) { mock(:length => 50) }
      let(:max_length) { nil }

      it { should be_nil }
    end
  end

  it { should respond_to(:validate_length?) }

  describe ".validate_length?" do
    subject { model_class.validate_length?(property_name, value, max_length) }
    let(:max_length) { 16 }

    context "when value is longer than max_length" do
      let(:value) { 'a' * (max_length + 1) }

      it { should be_false }
    end

    context "when value is shorter than max_length" do
      let(:value) { 'a' * (max_length - 1) }

      it { should be_true }
    end

    context "when value is the same length as max_length" do
      let(:value) { 'a' * max_length }

      it { should be_true }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { should be_true }
    end

    context "when max_length is nil" do
      let(:value) { Object.new }
      let(:max_length) { nil }

      it { should be_true }
    end
  end

  it { should respond_to(:validate_length!) }

  describe ".validate_length!" do
    subject { model_class.validate_length!(property_name, value, max_length) }
    let(:max_length) { 8 }

    context "when value is longer than max_length" do
      let(:value) { 'a' * (max_length + 1) }

      it "should raise an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end

      it "should include the name in the error message" do
        expect { subject }.to raise_error { |e| e.message.should match(/#{property_name}/i) }
      end

      it "should include the max length in the error message" do
        expect { subject }.to raise_error { |e| e.message.should match(/#{max_length}/) }
      end
    end

    context "when value is shorter than max_length" do
      let(:value) { 'a' * (max_length - 1) }

      it "should not raise an error" do
        expect { subject }.to_not raise_error
      end
    end

    context "when value is nil" do
      let(:value) { nil }

      it "should not raise an error" do
        expect { subject }.to_not raise_error
      end
    end

    context "when max_length is nil" do
      let(:max_length) { nil }
      let(:value) { 'aaaaaaaaaaa' }

      it "should not raise an error" do
        expect { subject }.to_not raise_error
      end
    end
  end

  it { should respond_to(:add_validator) }

  context "with simple validated property" do
    before do 
      model_class.add_validator(property_name, &validator_block)
      model.send("#{property_name}=", property_value)
    end

    subject { model }

    let(:property_value) { '42' }

    let(:message_validator) { lambda { |val| val.to_i != 42 ? "#{property_name} must be 42" : nil } }
    let(:error_validator) { lambda { |val| val.to_i != 42 ? ArgumentError.new("#{property_name} must be 42") : nil } }

    describe ".validators" do
      let(:validator_block) { message_validator }

      subject { validators }
      let(:validators) { model_class.validators }

      it { should have(1).property }

      describe "[property_name]" do
        subject { prop_validators }
        let(:prop_validators) { validators[property_name] }

        it { should have(1).validator }

        describe "#first" do
          subject { prop_validators.first }

          it { should respond_to(:call) }
          it { should == validator_block }
        end
      end
    end

    context "with valid value" do
      context "with validator that returns an error message" do
        let(:validator_block) { message_validator }

        it_should_behave_like 'a valid model'
      end

      context "with validator that returns an error" do
        let(:validator_block) { error_validator }

        it_should_behave_like 'a valid model'
      end
    end

    context "with invalid value" do
      let(:property_value) { 'not valid' }

      context "with validator that returns an error message" do
        let(:validator_block) { message_validator }

        it_should_behave_like 'a model with an invalid property' do
          let(:error_count) { 1 }
        end
      end

      context "with validator that returns an error" do
        let(:validator_block) { error_validator }

         it_should_behave_like 'a model with an invalid property' do
          let(:error_count) { 1 }
        end
      end
    end
  end

  context "with property that has multiple validations" do
    before do
      model_class.add_validator(property_name, &nil_validator)
      model_class.add_validator(property_name, &int_validator)
      model.send("#{property_name}=", property_value)
    end

    subject { model }

    let(:nil_validator) { lambda { |val| val.nil? ? "#{property_name} should not be nil" : nil } }
    let(:int_validator) { lambda { |val| "#{property_name} must represent the integer 42" unless val.to_i == 42 } }

    let(:property_value) { '42' }

    describe ".validators" do
      subject { validators }
      let(:validators) { model_class.validators }

      it { should have(1).property }

      describe "[property_name]" do
        subject { prop_validators }
        let(:prop_validators) { validators[property_name] }

        it { should have(2).validators }

        describe "#first" do
          subject { prop_validators.first }
          it { should respond_to(:call) }
          it { should == nil_validator }
        end

        describe "#last" do
          subject { prop_validators.last }
          it { should respond_to(:call) }
          it { should == int_validator }
        end
      end
    end

    context "with valid value" do
      it { should be_valid }

      describe "#validate" do
        subject { model.validate }

        it { should be_empty }
      end

      describe "#validate!" do
        subject { model.validate! }

        it "should not raise any errors" do
          expect { subject }.to_not raise_error
        end
      end
    end

    context "with nil value" do
      let(:property_value) { nil }

      it { should_not be_valid }

      describe "#validate" do
        subject { errors }
        let(:errors) { model.validate }

        it { should have(1).property }

        it { should have_key(property_name) }

        describe "[property_name]" do
          subject { prop_errors }
          let(:prop_errors) { errors[property_name] }

          it { should have(2).errors }

          describe "#first" do
            subject { prop_errors.first }

            it { should be_a ArgumentError }
            its(:message) { should match(/#{property_name}/i) }
            its(:message) { should match(/nil/i) }
          end

          describe "#last" do
            subject { prop_errors.last }

            it { should be_a ArgumentError }
            its(:message) { should match(/#{property_name}/i) }
            its(:message) { should match(/integer/i) }
          end
        end
      end

      describe "#validate!" do
        subject { model.validate! }

        it "should raise an ArgumentError" do
          expect { subject }.to raise_error(ArgumentError)
        end

        it "should reference the property name in the error message" do
          expect { subject }.to raise_error { |e| e.message.should match(/#{property_name}/i) }
        end
      end
    end
  end
end
