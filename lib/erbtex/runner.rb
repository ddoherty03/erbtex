# frozen_string_literal: true

require 'tempfile'
require 'pathname'
require 'English'

# Name space module for erbtex program.
module ErbTeX
  # Perform the erubis pre-processing and the TeX processing on the input
  # file. Return an exit status; preprocessing errors propagate to the caller.
  def self.run(cmd_line)
    return report_version if cmd_line.print_version

    if cmd_line.print_help
      report_help
      return 0
    end

    if cmd_line.preprocess_only && !cmd_line.input_file
      raise NoInputFile, '--preprocess-only requires an input file'
    end

    in_dir = parse_file_name(cmd_line.input_file)[:dir] if cmd_line.input_file
    tex_file = erb_to_tex(cmd_line.input_file, in_dir) if cmd_line.input_file
    return 0 if cmd_line.preprocess_only

    run_tex(cmd_line.tex_command(tex_file), in_dir)
  end

  def self.report_version
    puts "erbtex version: #{ErbTeX::VERSION}"
    puts "Ruby version: #{RUBY_VERSION}"
    begin
      erubis_version = %x(erubis -v)
    rescue Errno::ENOENT
      warn 'Warning: erubis does not appear to be installed!'
      return 1
    end
    puts "erubis version: #{erubis_version}"
    0
  end

  # Display the help for erbtex.
  def self.report_help
    puts <<~HELP
      Usage: erbtex [erbtex_options] [tex_prog_args] [file]

      erbtex_options are:
        --version           - print the version of the erbtex gem, ruby and erubis
        --help              - print this help message
        --preprocess-only   - generate the preprocessed file without invoking TeX
                              (requires an input file)
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
    unless system(new_env, [cmd.first, cmd.first], *cmd.drop(1))
      warn "Call to '#{cmd.shelljoin}' failed."
      return $CHILD_STATUS.exitstatus || 128 + $CHILD_STATUS.termsig
    end
    # Run a second time unless its latexmk
    unless File.basename(cmd.first) == 'latexmk'
      warn "TEXINPUTS set to: #{new_env['TEXINPUTS']}"
      unless system(new_env, [cmd.first, cmd.first], *cmd.drop(1))
        warn "Call to '#{cmd.shelljoin}' failed."
        return $CHILD_STATUS.exitstatus || 128 + $CHILD_STATUS.termsig
      end
    end
    $CHILD_STATUS.exitstatus
  end

  # Pre-process the input file with erubis, adding the in_dir to the front of
  # the ruby load path if its not already in the load path so that requires in
  # the input file can be found if they are in the in_dir.  Return the name of
  # the output file.
  def self.erb_to_tex(in_file, in_dir = nil)
    warn '================================================================'
    warn 'Erubis phase of processing ...'
    # Add input to ruby LOAD_PATH, $:,if its not already there.
    if in_dir && File.exist?(in_dir)
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
    rendered = ::Erubis::Eruby.new(in_contents, pattern: pat, filename: in_file).result
    warn "  Erubis writing to #{out_file}..."
    # Keep the temporary file beside its destination so rename is atomic.
    Tempfile.create([".#{File.basename(out_file)}-", '.tmp'], File.dirname(out_file)) do |f|
      f.write(rendered)
      f.close
      File.rename(f.path, out_file)
    end
    warn 'done'
    warn '================================================================'
    out_file
  end
end
