require 'spec_helper'

describe Modelish::Base do
  subject { model_class } 
  let(:model_class) { Class.new(Modelish::Base) }
  let(:model) { model_class.new }

  it { should respond_to(:property) }

  describe "simple property" do
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

  describe "property with default value" do
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

  describe "property with translated key" do
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

  describe ".new with typed property" do
    before { model_class.property(property_name, :type => property_type) }
    let(:property_name) { :my_property }
    let(:default_value) { nil }

    subject { model }

    context "when :type => Integer" do
      let(:property_type) { Integer }

      it_should_behave_like 'a typed property', :my_property, Integer do
        let(:valid_string) { '42' }
        let(:valid_typed_value) { 42 }
        let(:invalid_value) { 'forty-two' }
      end
    end

    context "when :type => Float" do
      let(:property_type) { Float }

      it_should_behave_like 'a typed property', :my_property, Float do
        let(:valid_string) { '42.5' }
        let(:valid_typed_value) { 42.5 }
        let(:invalid_value) { 'forty-two point five' }
      end
    end

    context "when :type => Date" do
      let(:property_type) { Date }

      it_should_behave_like 'a typed property', :my_property, Date do
        let(:valid_string) { '2011-03-10' }
        let(:valid_typed_value) { Date.civil(2011, 03, 10) }
        let(:invalid_value) { 'foo' }
      end
    end

    context "when :type => String" do
      let(:property_type) { String }

      it_should_behave_like 'a typed property', :my_property, String do
        let(:valid_string) { 'my_string' }
        let(:valid_typed_value) { valid_string }
      end
    end

    context "when :type => Symbol" do
      let(:property_type) { Symbol }

      it_should_behave_like 'a typed property', :my_property, Symbol do
        let(:valid_string) { 'MyCrazy    String' }
        let(:valid_typed_value) { :my_crazy_string }
        let(:invalid_value) { Array.new }
      end
    end

    context "when :type => Array" do
      let(:property_type) { Array }

      it_should_behave_like 'a typed property', :my_property, Array do
        let(:valid_string) { 'my valid string' }
        let(:valid_typed_value) { ['my valid string'] }
      end
    end
  end
end
