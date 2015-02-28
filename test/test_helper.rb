
# Set up load path for tests.

lib_dir = File.dirname(__FILE__) + '/../lib'
$:.unshift lib_dir unless $:.include?(lib_dir)

# require 'test/unit'
require 'minitest/autorun'
require 'erbtex'
require 'fileutils'
