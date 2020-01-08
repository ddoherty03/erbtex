require 'tempfile'
require 'pathname'
require 'English'

# Name space module for erbtex program.
module ErbTeX
  # Perform the erubis pre-processing and the TeX processing on the input
  # file.
  def self.run(cmd_line)
    report_version && exit(0) if cmd_line.print_version
    report_help && exit(0) if cmd_line.print_help

    in_dir = parse_file_name(cmd_line.input_file)[:dir]
    tex_file = erb_to_tex(cmd_line.input_file, in_dir) if cmd_line.input_file
    run_tex(cmd_line.tex_command(tex_file), in_dir)
  end

  def self.report_version
    puts "erbtex version: #{ErbTeX::VERSION}"
    puts "Ruby version: #{RUBY_VERSION}"
    begin
      erubis_version = `erubis -v`
    rescue Errno::ENOENT
      warn 'Warning: erubis does not appear to be installed!'
      exit(1)
    end
    puts "erubis version: #{erubis_version}"
    true
  end

  # Display the help for erbtex.
  def self.report_help
    puts <<~HELP
      Usage: erbtex [erbtex_options] [tex_prog_args] [file]

      erbtex_options are:
        --version           - print the version of the erbtex gem, ruby and erubis
        --help              - print this help message
        --invoke=<tex_prog> - after pre-processing, invoke <tex_prog> on the
                              resulting file, tex_prog is pdflatex by default

      All other arguments, except possibly the last, are passed unaltered to
      the tex_prog for interpretation.  If any of these arguments starts with a
      '\\' or '&', then all remaining arguments are passed to tex-prog for
      interpretation, even the final argument.

      The last argument is taken as the input file name unless it  or any earlier
      argument starts with a '\\' or '&', in which case it is also passed along
      as an argument to the tex-prog.

    HELP
    true
  end

  # Run the TeX program on the erubis-processed output file, which is the
  # input file to the TeX program.  Return the exit status.
  def self.run_tex(cmd, in_dir = nil)
    # If the input file is located in another directory (in_dir), add that
    # directory to TEXINPUTS if its not already there so that the input file
    # can \include or \input files using relative file names.  Place it after
    # the current directory '.' so that an plain file name is still
    # interpreted relative to the current working directory.
    new_env = {}
    if in_dir
      in_dir = File.absolute_path(File.expand_path(in_dir))
      ENV['TEXINPUTS'] ||= ''
      unless ENV['TEXINPUTS'].split(File::PATH_SEPARATOR)
               .reject { |p| p.strip.empty? }
               .any? { |p| in_dir == File.absolute_path(File.expand_path(p)) }
        new_env['TEXINPUTS'] = ".:#{in_dir}:#{ENV['TEXINPUTS']}"
      end
    end
    # Call cmd with the environment augmented by possibly expanded TEXINPUTS
    # environment variable.
    warn "TEXINPUTS set to: #{new_env['TEXINPUTS']}"
    unless system(new_env, cmd)
      warn "Call to '#{cmd}' failed."
      exit $CHILD_STATUS.to_i
    end
    # Run a second time unless its latexmk
    unless cmd =~ /\A *latexmk/
      warn "TEXINPUTS set to: #{new_env['TEXINPUTS']}"
      unless system(new_env, cmd)
        warn "Call to '#{cmd}' failed."
        exit $CHILD_STATUS.to_i
      end
    end
    $CHILD_STATUS
  end

  # Pre-process the input file with erubis, adding the in_dir to the front of
  # the ruby load path if its not already in the load path so that requires in
  # the input file can be found if they are in the in_dir.  Return the name of
  # the output file.
  def self.erb_to_tex(in_file, in_dir = nil)
    warn '================================================================'
    warn 'Erubis phase of processing ...'
    # Add input to ruby LOAD_PATH, $:,if its not already there.
    if File.exist?(in_dir)
      in_dir = File.absolute_path(File.expand_path(in_dir))
      unless $LOAD_PATH
               .any? { |p| in_dir == File.absolute_path(File.expand_path(p)) }
        $LOAD_PATH.unshift(in_dir)
      end
    end

    # Read the input
    warn "  Erubis reading from #{in_file}..."
    in_contents = nil
    File.open(in_file) do |f|
      in_contents = f.read
    end
    # TODO: recurse through any \input or \include commands

    pat = ENV['ERBTEX_PATTERN'] || '{: :}'

    out_file = ErbTeX.out_file_name(in_file)
    warn "  Erubis writing to #{out_file}..."
    File.open(out_file, 'w') do |f|
      er = ::Erubis::Eruby.new(in_contents, pattern: pat)
      f.write(er.result)
    end
    warn 'done'
    warn '================================================================'
    out_file
  rescue SystemCallError => e
    warn "Error: #{e}"
    exit 1
  rescue ScriptError => e
    warn "Erubis pre-processing failed: #{e}"
    exit 1
  end
end
