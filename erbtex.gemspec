# -*- encoding: utf-8 -*-

require "./lib/erbtex/version.rb"

Gem::Specification.new do |gem|
  gem.name = %q{erbtex}
  gem.version = ErbTeX::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.date = %q{2012-05-13}
  gem.homepage = 'https://github.com/ddoherty03/erbtex'
  gem.authors = ['Daniel E. Doherty']
  gem.email = %q{ded@ddoherty.net}
  gem.summary = %q{Preprocesses TeX and LaTeX files with erubis for ruby.}
  gem.description = %q{erbtex will act just like pdflatex except that it will
                     process ruby fragments between {: and :} markers,
                     greatly expanding the ability to generate
                     automated TeX and LaTeX documents.}
  gem.files         = `git ls-files`.split("\n")
  gem.files.delete_if { |f| f =~ /\.(log|etc|aux|etx|pdf|gem|tmp)$/ }
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency 'erubis'
  gem.add_dependency 'fat_core'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-doc'
  gem.add_development_dependency 'pry-byebug'
end
