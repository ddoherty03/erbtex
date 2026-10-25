# frozen_string_literal: true

# Conditional added to prevent running bundler/setup twice when it already has
# erbtex in the LOAD_PATH.  Failure to do this was causing bundler to setup for
# the wrong Gemfile if it was run in the development directory of another gem,
# for example, ydl.  This only happened on saturn for some reason that I don't
# understand, but this kludge made it work.

require 'bundler/setup' if $LOAD_PATH.none? { |p| p.include?('erbtex') }

require 'shellwords'
require 'erubis'
require 'fat_core'

require 'erbtex/version'
require 'erbtex/command_line'
require 'erbtex/runner'
require 'erbtex/file_names'

# Gem Overview (extracted from README.org by gem_docs)
#
# * Introduction
# ~erbtex~ is a ruby gem that provides the ~erbtex~ command line program that
# pre-processes TeX and LaTeX source files with ruby's [[http://www.kuwata-lab.com/erubis][erubis]] and then passes
# the resulting file along to a real TeX program for compilation.  This
# allows your TeX or LaTeX documents to do arbitrary calculations using
# Ruby code when doing so in LaTeX would be infeasible.
#
# For example, the [[file:examples/TrigTable.tex][trigonometry table source]] uses Ruby to compute
# and format the values, while LaTeX lays out the table across multiple pages.
# [[file:examples/TrigTable.pdf][View the typeset output (PDF)]] for the complete 32-page table.
#
# Here is an excerpt from the first page:
#
# [[file:examples/TrigTable-preview.png]]
module Erbtex
end
