require 'rake/testtask'

task :default => :test

# Rake::TestTask.new do |t|
#   t.libs << "test"
#   t.ruby_opts = ["-C test"] #, "-C test"]
#   files = FileList['test/test_*.rb']
#   files.delete('test/test_helper.rb')
#   #files = files.map { |f| f[5..-1] }
#   t.test_files = files
#   t.verbose = true
# end

desc "Run all the unit tests"
task :test do
  Dir.foreach('test') do |t|
    next if t == 'test_helper.rb'
    next if t =~ /^\.\.?/
    cmd = "ruby -I 'test' -C 'test' #{t}"
    system cmd
  end
end
