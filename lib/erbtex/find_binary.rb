require 'ruby-debug'

module ErbTeX
  # Find the first executable file in the PATH that is the same
  # basename, but not the same absolute name as calling_prog.  If this
  # program has been linked to the name pdflatex, for example, and is
  # located in ~/bin/pdflatex, this function will take '~/bin/pdflatex'
  # as it parameter, expand it to /home/ded/pdflatex, then walk through
  # the PATH looking for an executable with the same basename, pdflatex,
  # but not the same absolute name /home/ded/bin/pdflatex.
  #
  # This allows us to make several symlinks to our erbtex program with
  # the name of the actual program we want to invoke.  So our link
  # version of pdflatex will know to invoke the *real* pdflatex in
  # /usr/bin/pdflatex after we've done the pre-processing.  Also, other
  # programs that want to invoke pdflatex will still work, except that
  # we'll sneak in and do ruby pre-processing before invoking the real
  # program.
  
  def ErbTeX.find_binary(calling_prog)
    calling_prog = File.absolute_path(calling_prog)
    call_path = File.dirname(calling_prog)
    call_base = File.basename(calling_prog)
    ENV['PATH'].split(':').each do |p|
      next unless File.directory?(p)
      next if File.absolute_path(p) == call_path
      Dir.foreach(p) do |f|
        path = p + '/' + f
        if f == call_base and File.executable?(path)
          return path
        end
      end
    end
  end
end
