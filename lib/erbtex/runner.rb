module ErbTeX
  # When we are handed a command line, it will be one that was
  # originally intended for the real tex processor, e.g., pdflatex.
  #
  # We want to find the intended input file and the intended output
  # directory using the ErbTeX::CommandLine object.
  #
  # We want to process the intended input file with Erubis and save the
  # output in a temporary file with an .etx extension.
  #
  # Write the .etx file to the current directory unless it is not
  # writable, in which case write it to /tmp.
  #
  # Perhaps change the Erubis pattern to something like .{ }. so that
  # AucTeX does not get confused with the comment character used in
  # Erubis by default (<%= %>).
  # 
  # If there are no Erubis patterns in the file, skip the Erubis phase
  # and just pass the original command on to the system.
  #
  # If there is an error in the Erubis phase, we want the error message
  # to make it clear what happened and exit without invoking the tex
  # processor.
  # 
  # We want to find the real tex processor with find_binary and run it
  # on our processed .etx file and otherwise leave the commandline
  # intact.
  # 
  def run
    case File.extname(@file)
    when ''
      erb_file = "#{@file}.tex"
      erb_base = File.basename(erb_file, '.tex')
    when '.tex'
      erb_file = @file
      erb_base = File.basename(erb_file, '.tex')
    when '.texi'
      erb_file = @file
      erb_base = File.basename(erb_file, '.texi')
    else
      raise "File #{@file} must have '.tex' or 'texi' extension."
    end
    erb_file = File.expand_path(erb_file)
    unless File.readable?(erb_file)
      raise "File #{erb_file} not readable"
    end

    # Run ERB, then TeX processor
    tex_file = "#{erb_base}.etx"
    if process(erb_file, tex_file)
      commandline = "#{@texprog} #{@texopts}"
      commandline = commandline.sub(/\^f\^/, tex_file)
      commandline = commandline.gsub(/([^ \t]+)/, '\'\1\'')
      puts "TeX Command: #{commandline}\n"
      # Remove /usr/local/bin from PATH before execution,
      # so we don't invoke erbtex again via a symlink
      path = ENV['PATH'].split(':')
      path.delete("/usr/local/bin")
      path = path.join(':')
      system({'PATH' => path}, "#{commandline}")
    end
  end

  def process(in_file, out_file)
    unless File.new(out_file, "a")
      raise "Cannot write to output file #{out_file} in #{Dir.getwd}\n"
    end
    # Process with erubis, testing for ruby syntax errors first
    #status = system("erubis -z #{erubyopts} \"#{in_file}\" >/dev/null 2>&1")
    erubis_command = "erubis \"#{in_file}\" >\"#{out_file}\""
    puts "Erubis Command: #{erubis_command}"
    status = system(erubis_command)
    unless (status)
      STDERR.print "Problem with erubis syntax check.\n"
    end
    return status
  end
end
