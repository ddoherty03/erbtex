require 'rake/testtask'

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test
desc "Run all the unit tests"
task :test do
  Dir.foreach('test') do |t|
    next if t == 'test_helper.rb'
    next if t =~ /^\.\.?/
    cmd = "ruby -I 'test' -C 'test' #{t}"
    system cmd
  end
end
