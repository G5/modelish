# modelish #

When a real modeling framework is too heavy, sometimes you want something just 
a little modelish.

If a Hash or OpenStruct almost suits your needs, but you need bits of 
model-like behavior such as simple validation and typed values, modelish can 
help.

If you need persistence or anything but the most basic functionality, modelish 
will frustrate you to no end.

modelish has not been officially released yet, and may change at any time.

## Installation ##

For the especially foolhardy, you can:

1. Add this to your Gemfile:

         gem 'modelish', :git => 'git://github.com/maeve/modelish.git'

2. Execute `bundle install`

## Basics ##

The modelish syntax is very similar to some of the classes provided by 
[hashie]. In fact, the initial implementation simply extends 
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

**TODO:** modelish will eventually support simple validations.

 [hashie]: https://github.com/intridea/hashie
 [trash]: http://rdoc.info/github/intridea/hashie/master/Hashie/Trash
