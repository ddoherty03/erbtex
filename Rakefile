# frozen_string_literal: true

require 'bundler/gem_tasks'

# Installing into the user's gems must not inherit this project's bundle.
# RubyGems plugins (notably RDoc) may require dependencies outside that bundle.
module UnbundledGemInstallation
  def install_gem(*args)
    Bundler.with_unbundled_env { super }
  end
end

Bundler::GemHelper.prepend(UnbundledGemInstallation)

require 'rspec/core/rake_task'

require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib')
end
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec rubocop]
