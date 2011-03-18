require 'spec_helper'

describe Modelish::Base do
  subject { model_class } 
  let(:model_class) { Class.new(Modelish::Base) }

  let(:model) { model_class.new(init_options) }
  let(:init_options) { nil }
  let(:default_value) { nil }

  it { should respond_to(:property) }

  context "with simple property" do
    before { model_class.property(property_name) }

    let(:property_name) { :simple_property }
    let(:property_value) { 'simple string value' }

    it_should_behave_like 'a modelish property'
    it_should_behave_like 'a valid model'
  end

  context "with property default value" do
    before { model_class.property(property_name, :default => default_value) }

    let(:property_name) { :default_property }
    let(:property_value) { 'non-default value' }
    let(:default_value) { 42 }

    it_should_behave_like 'a modelish property'
    it_should_behave_like 'a valid model'
  end

  context "with translated property" do
    before { model_class.property(property_name, :from => from_name) }

    subject { model }

    let(:property_name) { :translated_property }
    let(:from_name) { 'OldPropertyNAME' }
    let(:property_value) { 'new value' }

    it_should_behave_like 'a modelish property'

    it { should_not respond_to(from_name) }
    it { should respond_to("#{from_name}=") }

    describe "original setter" do
      subject { model.send("#{from_name}=", property_value) }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end

    it_should_behave_like 'a valid model'
  end

  context "with typed property" do
    before { model_class.property(property_name, options) }

    subject { model }

    let(:property_name) { :my_int_property }
    let(:property_type) { Integer }

    let(:valid_string) { '42' }
    let(:valid_typed_value) { 42 }
    let(:invalid_value) { '42.0' }

    context "without default value" do
      let(:options) { {:type => property_type} }
      let(:default_value) { nil }

      context "without init options" do
        it_should_behave_like 'a typed property', :my_int_property, Integer
        it_should_behave_like 'a valid model'
      end

      context "with init options" do
        let(:model) { model_class.new(property_name => valid_string) }

        its(:my_int_property) { should == valid_typed_value }
        its(:raw_my_int_property) { should == valid_string }

        it_should_behave_like 'a valid model'
      end
    end

    context "with default value" do
      let(:options) { {:type => property_type, :default => default_value} }
      let(:default_value) { 0 }

      it_should_behave_like 'a typed property', :my_int_property, Integer

      it_should_behave_like 'a valid model'
    end
  end

  context "with required property" do
    before { model_class.property(property_name, :required => true) }

    let(:property_name) { :my_required_property }
    let(:property_value) { 'a valid string' }

    subject { model }

    let(:init_options) { {property_name => property_value} }

    it_should_behave_like 'a modelish property'

    context "when property value is not nil" do
      it_should_behave_like 'a valid model'
    end

    context "when property value is nil" do
      let(:property_value) { nil }

      it_should_behave_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end

    context "when property value is an empty string" do
      let(:property_value) { '          ' }

      it_should_behave_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end
  end

  context "with length-restricted property" do
    before { model_class.property(property_name, :required => false, :max_length => max_length) }

    let(:property_name) { :my_required_property }
    let(:property_value) { 'a' * (max_length - 1) }
    let(:max_length) { 10 }

    subject { model }

    let(:init_options) { {property_name => property_value} }

    it_should_behave_like 'a modelish property'

    context "when property value is nil" do
      let(:property_value) { nil }

      it_should_behave_like 'a valid model'
    end

    context "when property value is a valid string" do
      it_should_behave_like 'a valid model'
    end

    context "when property value is too long" do
      let(:property_value) { 'a' * (max_length + 1) }

      it_should_behave_like 'a model with an invalid property' do
        let(:error_count) { 1 }
      end
    end
  end

  context "with validator block" do
  end

  context "with type validation enabled" do
  end

  context "with multiple validations" do
  end
end
