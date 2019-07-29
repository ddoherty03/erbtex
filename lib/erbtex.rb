# Conditional added to prevent running bundler/setup twice when it already has
# erbtex in the LOAD_PATH.  Failure to do this was causing bundler to setup for
# the wrong Gemfile if it was run in the development directory of another gem,
# for example, ydl.  This only happened on saturn for some reason that I don't
# understand, but this kludge made it work.

require 'bundler/setup' if $LOAD_PATH.none? { |p| p =~ /erbtex/ }

require 'shellwords'
require 'erubis'
require 'fat_core'

require 'erbtex/version'
require 'erbtex/command_line'
require 'erbtex/runner'
require 'erbtex/file_names'
