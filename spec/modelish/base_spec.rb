require 'spec_helper'

describe Modelish::Base do
  subject { model_class } 
  let(:model_class) { Class.new(Modelish::Base) }
  let(:model) { model_class.new }

  it { should respond_to(:property) }

  describe "with simple property" do
    before { model_class.property(property_name) }

    subject { model }

    let(:property_name) { :simple_property }

    it { should respond_to(property_name) }
    it { should respond_to("#{property_name}=".to_sym) }

    its(:simple_property) { should be_nil }

    describe "simple_property=" do
      subject { model.simple_property = property_value }
      let(:property_value) { 'simple string value' }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end
  end

  describe "with property default value" do
    before { model_class.property(property_name, :default => default_value) }
    let(:property_name) { :default_property }
    let(:default_value) { 42 }

    subject { model }

    it { should respond_to(property_name) }
    it { should respond_to("#{property_name}=".to_sym) }

    its(:default_property) { should == default_value }

    describe "default_property=" do
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

  describe "with translated property" do
    before { model_class.property(property_name, :from => from_name) }
    let(:property_name) { :translated_property }
    let(:from_name) { 'OldPropertyNAME' }

    subject { model }

    it { should respond_to(property_name) }
    it { should respond_to("#{property_name}=") }
    it { should_not respond_to(from_name) }
    it { should respond_to("#{from_name}=") }

    its(:translated_property) { should be_nil }

    describe "translated_property=" do
      subject { model.translated_property = property_value }
      let(:property_value) { 'new value' }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end

    describe "OldPropertyNAME=" do
      subject { model.OldPropertyNAME = property_value }
      let(:property_value) { 'new property value' }

      it "should change the property value" do
        expect { subject }.to change{model.send(property_name)}.from(nil).to(property_value)
      end
    end
  end

  describe "with typed property" do
    before { model_class.property(property_name, options) }

    let(:property_name) { :my_int_property }
    let(:property_type) { Integer }
    let(:valid_string) { '42' }
    let(:valid_typed_value) { 42 }
    let(:invalid_value) { '42.0' }

    context "without default value" do
      let(:options) { {:type => property_type} }

      it_should_behave_like 'a typed property', :my_int_property, Integer do
        let(:default_value) { nil }
      end
    end

    context "with default value" do
      let(:options) { {:type => property_type, :default => default_value} }

      let(:default_value) { 0 }

      it_should_behave_like 'a typed property', :my_int_property, Integer
    end
  end
end
