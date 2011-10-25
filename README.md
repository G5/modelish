# modelish #

When a real modeling framework is too heavy, sometimes you want something just 
a little modelish.

## Overview ##

If a Hash or OpenStruct almost suits your needs, but you need bits of 
model-like behavior such as simple validation and typed values, modelish can 
help.

If you need persistence or anything but the most basic functionality, modelish 
will frustrate you to no end.

## Documentation ##

See the [rdocs][docs].

## Installation ##

modelish is available on [Rubygems][rubygems] and can be installed via:

         $ gem install modelish

## Basics ##

### Property Types ###

The modelish syntax is very similar to some of the classes provided by 
[hashie]. In fact, the initial implementation simply extended 
[Hashie::Trash][trash] to add property types:

        require 'modelish'

        class Foo < Modelish::Base
          property :my_date, :type => Date
          property :my_float, :type => Float, :default => 0.0
          property :my_funky_id, :type => Integer, :from => 'MyFUNKYId'
          property :my_simple_property
        end

You can then set properties as string value and have them automatically 
converted to the appropriate type, while respecting default values and 
key-mappings:

       f = Foo.new('MyFUNKYId' => '42', 
                   :my_date => '2011-03-10', 
                   :my_simple_property => 'bar')

       f.my_date
       # => #<Date: 2011-03-10 (4911261/2,0,2299161)> 
       f.my_float
       # => 0.0 
       f.my_funky_id
       # => 42 
       f.my_simple_property
       # => "bar" 

### Property Validation ###

modelish also supports defining simple property validations:

        class Bar < Modelish::Base
          property :important_field, :required => true
          property :state, :max_length => 2
          property :my_int, :type => Integer, :validate_type => true
          property :another_field, :validator => lambda { |val| "val must respond to []" unless val.respond_to?(:[]) }
        end

Validations can be run using methods that return an error map (keyed on property name), raise errors, or return a boolean value to indicate validation outcome.

        valid_bar = Bar.new(:important_field => 'some value', 
                            :state => 'OR', 
                            :my_int => 42, 
                            :another_field => Hash.new)
        valid_bar.valid?
        # => true

        valid_bar.validate
        # => {}

        valid_bar.validate!
        # => nil


        invalid_bar = Bar.new(:state => 'a value that is too long',
                              :my_int => 'this is not an integer',
                              :another_field => Object.new)
        invalid_bar.valid?
        # => false

        invalid_bar.validate
        # => {:important_field=>[#<ArgumentError: important_field must not be nil or blank>],
        # :my_int=>[#<ArgumentError: my_int must be of type Integer, but got "this is not an integer">],
        # :another_field=>[#<ArgumentError: val must respond to []>], 
        # :state=>[#<ArgumentError: state must be less than 2 characters>]}

        invalid_bar.validate!
        # ArgumentError: important_field must not be nil or blank

## Configuration ##

By default, modelish will raise an error when it encounters unknown property names in an initialization hash. If you'd prefer modelish to ignore unknown properties, you can override this default behavior for all of your modelish models:

        require 'modelish'

        Modelish.configure do |config|
          config.ignore_unknown_properties = true
        end

        class MyModel < Modelish::Base
          property :foo
        end

        m = MyModel.new(:foo => 'value', :bar => true)
        # => <#MyModel foo="value">

Or you can selectively enable the setting for a particular model:

        require 'modelish'

        class MyPermissiveModel < Modelish::Base
          property :foo
          ignore_unknown_properties!
        end

        class MyStrictModel < Modelish::Base
          property :foo
        end

        p = MyPermissiveModel.new(:foo => 'value', :bar => true)
        # => <#MyPermissiveModel foo="value">

        s = MyStrictModel.new(:foo => 'value', :bar => true)
        # NoMethodError: The property 'bar' is not defined for this Modelish object

 [hashie]: https://github.com/intridea/hashie
 [trash]: http://rdoc.info/github/intridea/hashie/master/Hashie/Trash
 [rubygems]: https://rubygems.org/gems/modelish
 [docs]: http://rubydoc.info/gems/modelish
