# modelish #

When a real modeling framework is too heavy, sometimes you want something just 
a little modelish.

If a Hash or OpenStruct almost suits your needs, but you need bits of 
model-like behavior such as simple validation and typed values, modelish can 
help.

If you need persistence or anything but the most basic functionality, modelish 
will frustrate you to no end.

## Installation ##

modelish is available on [Rubygems][rubygems] and can be installed via:

         $ gem install modelish

## Basics ##

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
         => #<Date: 2011-03-10 (4911261/2,0,2299161)> 
       f.my_float
         => 0.0 
       f.my_funky_id
         => 42 
       f.my_simple_property
         => "bar" 

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
          => true

        valid_bar.validate
          => {}

        valid_bar.validate!
          => nil


        invalid_bar = Bar.new(:state => 'a value that is too long',
                              :my_int => 'this is not an integer',
                              :another_field => Object.new)
        invalid_bar.valid?
          => false

        invalid_bar.validate
          => {:important_field=>[#<ArgumentError: important_field must not be nil or blank>], :my_int=>[#<ArgumentError: my_int must be of type Integer, but got "this is not an integer">], :another_field=>[#<ArgumentError: val must respond to []>], :state=>[#<ArgumentError: state must be less than 2 characters>]}

        invalid_bar.validate!
          ArgumentError: important_field must not be nil or blank
                  from /Users/maeverevels/projects/modelish/lib/modelish/validations.rb:31:in `validate!'
                  ...

 [hashie]: https://github.com/intridea/hashie
 [trash]: http://rdoc.info/github/intridea/hashie/master/Hashie/Trash
 [rubygems]: https://rubygems.org/gems/modelish
