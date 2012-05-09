
task :default => :test_all

desc "Run all the unit tests"
task :test_all do
  Dir.foreach('test') do |t|
    next if t == 'test_helper.rb'
    next if t =~ /^\.\.?/
    cmd = "ruby -C 'test' #{t}"
    system cmd
  end
end
