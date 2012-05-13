Gem::Specification.new do |s|
  s.name = %q{erbtex}
  s.version = "0.1.1"
  s.date = %q{2012-05-13}
  s.authors = ["Daniel E. Doherty"]
  s.email = %q{ded-erbtex@ddoherty.net}
  s.summary = %q{Preprocesses TeX and LaTeX files with erubis for ruby.}
  s.description = %q{Create a local link called pdflatex to erbtex and it will
                     act just like pdflatex except that it will process ruby fragments
                     between .{ and }. markers, greatly expanding the ability to generate
                     automated TeX and LaTeX documents.}
  s.files = Dir.glob(['./*', './*/**'])
  s.files.delete_if {|f| f =~ /(log|etc|aux)$/}
end
