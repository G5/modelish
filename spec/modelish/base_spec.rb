require 'spec_helper'

describe Modelish::Base do
  subject { model_class } 
  let(:model_class) { Class.new(Modelish::Base) }
  let(:model) { model_class.new }

  it { should respond_to(:property) }

  context "with simple property" do
    before { model_class.property(property_name) }

    subject { model }

    let(:property_name) { :simple_property }
    let(:property_value) { 'simple string value' }

    it { should respond_to(property_name) }
    it { should respond_to("#{property_name}=".to_sym) }

    describe "getter" do
      subject { model.send(property_name) }

      context "without init options" do
        it { should be_nil }
      end

      context "with init options" do
        let(:model) { model_class.new(property_name => property_value) }

        it { should == property_value }
      end
    end

    describe "setter" do
      subject { model.simple_property = property_value }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end
  end

  context "with property default value" do
    before { model_class.property(property_name, :default => default_value) }

    subject { model }

    let(:property_name) { :default_property }
    let(:default_value) { 42 }

    it { should respond_to(property_name) }
    it { should respond_to("#{property_name}=".to_sym) }

    describe "getter" do
      subject { model.send(property_name) }

      context "without init options" do
        it { should == default_value }
      end

      context "with init options" do
        let(:model) { model_class.new(property_name => property_value) }
        let(:property_value) { 'non-default value' }

        it { should == property_value }
      end
    end

    describe "setter" do
      subject { model.default_property = property_value }

      context "with nil" do
        let(:property_value) { nil }

        it "should set the value to nil" do
          expect { subject }.to change{model.send(property_name)}.from(default_value).to(nil)
        end
      end

      context "with non-nil value" do
        let(:property_value) { 'new value' }

        it "should change the property value" do
          expect { subject }.to change{model.send(property_name)}.from(default_value).to(property_value)
        end
      end
    end
  end

  context "with translated property" do
    before { model_class.property(property_name, :from => from_name) }

    subject { model }

    let(:property_name) { :translated_property }
    let(:from_name) { 'OldPropertyNAME' }
    let(:property_value) { 'new value' }

    it { should respond_to(property_name) }
    it { should respond_to("#{property_name}=") }
    it { should_not respond_to(from_name) }
    it { should respond_to("#{from_name}=") }

    describe "getter" do
      subject { model.send(property_name) }

      context "without init options" do
        it { should be_nil }
      end

      context "with init options" do
        let(:model) { model_class.new(from_name => property_value) }

        it { should == property_value }
      end
    end

    describe "translated setter" do
      subject { model.translated_property = property_value }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end

    describe "original setter" do
      subject { model.OldPropertyNAME = property_value }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end
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
      end

      context "with init options" do
        let(:model) { model_class.new(property_name => valid_string) }

        its(:my_int_property) { should == valid_typed_value }
        its(:raw_my_int_property) { should == valid_string }
      end
    end

    context "with default value" do
      let(:options) { {:type => property_type, :default => default_value} }
      let(:default_value) { 0 }

      it_should_behave_like 'a typed property', :my_int_property, Integer
    end
  end
end
