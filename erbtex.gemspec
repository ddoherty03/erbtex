# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "erbtex/version"

Gem::Specification.new do |s|
  s.name = %q{erbtex}
  s.version = ErbTeX::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = %q{2012-05-13}
  s.homepage = ""
  s.authors = ["Daniel E. Doherty"]
  s.email = %q{ded-erbtex@ddoherty.net}
  s.summary = %q{Preprocesses TeX and LaTeX files with erubis for ruby.}
  s.description = %q{Create a local link called pdflatex to erbtex and it will
                     act just like pdflatex except that it will process ruby fragments
                     between .{ and }. markers, greatly expanding the ability to generate
                     automated TeX and LaTeX documents.}

  s.files         = `git ls-files`.split("\n")
  s.files.delete_if {|f| f =~ /(log|etc|aux|etx|pdf|gem)$/}
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
