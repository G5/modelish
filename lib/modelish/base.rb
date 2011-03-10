require 'hashie'
require 'date'

module Modelish
  class Base < Hashie::Trash
    def self.property(name, options={})
      super

      if options[:type]
        if options[:type].to_s =~ /^date$/i
          converter = "Date.parse(raw_#{name}(&block).to_s)"
        elsif options[:type].to_s =~ /^symbol$/i
          converter = "raw_#{name}(&block).gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2')." +
                        "gsub(/([a-z\d])([A-Z])/, '\\1_\\2')." +
                        "gsub(/\s+|-/,'_').downcase.to_sym"
        else
          converter = "#{options[:type].to_s.capitalize}(raw_#{name}(&block))"
        end

        class_eval <<-RUBY
          alias :raw_#{name} :#{name}

          def #{name}!(&block)
            val = raw_#{name}(&block)
            val = #{converter} unless val.nil? || val.is_a?(#{options[:type].to_s.capitalize})
            val
          end

          def #{name}(&block)
            #{name}!(&block) rescue raw_#{name}(&block)
          end
        RUBY
      end
    end
  end
end
