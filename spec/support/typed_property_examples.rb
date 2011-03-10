# Assume the following are defined:
# model - the model on which the property is defined
# valid_string - a string with a valid value for the property
# valid_typed_value - an instance of property_type that is valid for the property
# invalid_value - an object that cannot be translated to the property type
# default_value - the default value for the property
shared_examples_for "a typed property" do |prop_name, prop_type|
  accessor = prop_name.to_sym
  raw_accessor = "raw_#{prop_name}".to_sym
  bang_accessor = "#{prop_name}!".to_sym
  mutator = "#{prop_name}=".to_sym

  subject { model }

  it { should respond_to(accessor) }
  its(prop_name) { should == default_value }

  it { should respond_to(raw_accessor) }
  its(raw_accessor) { should == default_value }

  it { should respond_to(bang_accessor) }
  its(bang_accessor) { should == default_value }

  it { should respond_to(mutator) }

  describe "assignment" do
    before { model.send(mutator, property_value) }

    context "with nil" do
      let(:property_value) { nil }

      its(accessor) { should be_nil }
      its(raw_accessor) { should be_nil }

      it "should not raise an error when the bang accessor is invoked" do
        expect { subject.send(bang_accessor) }.to_not raise_error
      end

      its(bang_accessor) { should be_nil }
    end

    context "with valid string" do
      let(:property_value) { valid_string }

      its(accessor) { should == valid_typed_value }
      its(raw_accessor) { should == property_value }

      it "should not raise an error when the bang accessor is invoked" do
        expect { subject.send(bang_accessor) }.to_not raise_error
      end

      its(bang_accessor) { should == valid_typed_value } 
    end

    context "with valid typed value" do
      let(:property_value) { valid_typed_value }

      its(accessor) { should == property_value }
      its(raw_accessor) { should == property_value }

      it "should not raise an error when the bang accessor is invoked" do
        expect { subject.send(bang_accessor) }.to_not raise_error
      end

      its(bang_accessor) { should == valid_typed_value }
    end

    unless [String, Array].include?(prop_type)
      context "with a value that cannot be converted" do
        let(:property_value) { invalid_value }

        its(accessor) { should == property_value }
        its(raw_accessor) { should == property_value }

        it "should raise an error when the bang accessor is invoked" do
          expect { subject.send(bang_accessor) } .to raise_error
        end
      end
    end
  end
end
