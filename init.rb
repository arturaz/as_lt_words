require File.join(File.dirname(__FILE__), 'lib', 'arturaz', 'as_lt_words.rb')

Date.send(:include, Arturaz::AsLtWords::DateExtensions::InstanceMethods)
Time.send(:include, Arturaz::AsLtWords::TimeExtensions::InstanceMethods)
Time.send(:private, :ago_as_lt_words, :since_as_lt_words)
Time.extend Arturaz::AsLtWords::TimeExtensions::ClassMethods
Integer.send(:include, Arturaz::AsLtWords::IntegerExtensions::InstanceMethods)