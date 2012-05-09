#! /usr/bin/env ruby

require 'erubis'

require 'erbtex/command_line'
require 'erbtex/find_binary'

module ErbTeX
  VERSION = ('$Release: 0.1.0 $' =~ /([.\d]+)/) && $1
end

