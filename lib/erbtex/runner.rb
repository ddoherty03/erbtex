require 'tempfile'
require 'pathname'

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
  # Perhaps change the Erubis pattern to something other than the erbtex
  # default '{: :}'.  Erubis normally by uses '<%= %>' by default.  Erubis -p
  # commandline -p '\.{ }\.'

  # If there are no Erubis patterns in the file, skip the Erubis phase
  # and just pass the original command on to the system.
  #
  # But wait.  What if there are \include{file} or \input file
  # statements in the input and those have Erubis patterns in them?  We
  #  have to invoke erbtex recursively on those, replacing the
  # orginal with a processed temporary and patching up the
  # \include{tmp-file}, and so on.
  #
  # If there is an error in the Erubis phase, we want the error message
  # to make it clear what happened and exit without invoking the tex
  # processor.
  #
  # We want to find the real tex processor with find_executable and run it
  # on our processed .etx file and otherwise leave the commandline
  # intact.
  #
  def self.run(cl)
    tex_file = erb_to_tex(cl.input_file) if cl.input_file
    unless system(cl.tex_command(tex_file))
      stderr.puts "Call to #{cl.tex_program} failed."
      exit $?
    end
  end

  def self.erb_to_tex(in_file)
    in_contents = nil
    File.open(in_file) do |f|
      in_contents = f.read
    end
    # TODO: recurse through any \input or \include commands

    pat =
      if ENV['ERBTEX_PATTERN']
        ENV['ERBTEX_PATTERN']
      else
        '{: :}'
      end

    out_file = set_out_file(in_file)
    File.open(out_file, 'w') do |f|
      er = ::Erubis::Eruby.new(in_contents, pattern: pat)
      f.write(er.result)
    end
    out_file
  rescue SystemCallError => ex
    $stderr.puts "Error: #{ex}"
    exit 1
  rescue ScriptError => ex
    $stderr.puts "Erubis pre-processing failed: #{ex}"
    exit 1
  end

  def self.set_out_file(in_file)
    in_file_absolute = File.absolute_path(File.expand_path(in_file))
    in_dir = in_file_absolute[/\A(.*\/)([^\/.]+)(\.[\w.]+)\z/, 1]
    in_base = in_file_absolute[/\A(.*\/)([^\/.]+)(\.[\w.]+)\z/, 2]
    in_ext = in_file_absolute[/\A(.*\/)([^\/.]+)(\.[\w.]+)\z/, 3]

    if in_ext.empty?
      if File.exists?("#{in_file}.tex.erb")
        out_ext = '.tex'
      elsif File.exists?("#{in_file}.tex")
        out_ext = '.etx'
      elsif File.exists?("#{in_file}.erb")
        out_ext = '.tex'
      else
        out_ext = '.tex'
      end
    else
      case in_ext
      when '.tex.erb'
        out_ext = '.tex'
      when '.tex'
        out_ext = '.etx'
      when '.erb'
        out_ext = '.tex'
      else
        out_ext = '.tex'
      end
    end

    # Find a writable directory, prefering the one the input file came
    # from, or the current directory, and a temp file as a last resort.
    if File.writable?(in_dir)
      out_file = File.join(in_dir, "#{in_base}#{out_ext}")
    elsif File.writable?('.')
      out_file = File.join('.', "#{in_base}#{out_ext}")
    else
      out_file = Tempfile.new([in_base, out_ext]).path
    end
    out_file
  end
end
  # def ErbTeX.run(command)
  #   cl = CommandLine.new(command)
  #   Dir.chdir(cl.run_dir) do
  #     if cl.input_file
  #       new_infile = process(cl.input_file, cl.input_path)
  #     else
  #       new_infile = nil
  #     end
  #     if new_infile
  #       new_infile = Pathname.new(new_infile).
  #                    relative_path_from(Pathname.new(cl.run_dir))
  #     end
  #     new_progname = ErbTeX.find_executable(command.lstrip.split(' ')[0])
  #     cmd = cl.new_command_line(new_progname, new_infile)
  #     cmd.sub!('\\', '\\\\\\')
  #     cmd.sub!('&', '\\\\&')
  #     puts "Executing: #{cmd}"
  #     system(cmd)
  #   end
  # end

  # Run erbtex on the content of file_name, a String, and return the
  # name of the file where the processed content can be found.  This
  # could be the orignal file name if no processing was needed, or a
  # temporary file if the erubis pattern is found anywhere in the file.
  # def ErbTeX.process(file_name, dir)
  #   puts "Input path: #{dir}"
  #   contents = nil
  #   File.open(file_name) do |f|
  #     contents = f.read
  #   end
  #   # TODO: recurse through any \input or \include commands

  #   # Add current directory to LOAD_PATH
  #   $: << '.' unless $:.include?('.')

  #   if ENV['ERBTEX_PATTERN']
  #     pat = ENV['ERBTEX_PATTERN']
  #   else
  #     pat = '{: :}'
  #   end

  #   # Otherwise process the contents
  #   # Find a writable directory, prefering the one the input file came
  #   # from, or the current directory, and a temp file as a last resort.
  #   file_absolute = File.absolute_path(File.expand_path(file_name))
  #   file_dir = File.dirname(file_absolute)
  #   if file_absolute =~ /\.tex\.erb$/
  #     file_base = File.basename(file_absolute, '.tex.erb')
  #   else
  #     file_base = File.basename(file_absolute, '.tex')
  #   end
  #   of = nil
  #   if File.writable?(file_dir)
  #     out_file = file_dir + '/' + file_base + '.etx'
  #   elsif File.writable?('.')
  #     out_file = './' + file_base + '.etx'
  #   else
  #     of = Tempfile.new([File.basename(file_name), '.etx'])
  #     out_file = of.path
  #   end
  #   unless of
  #     of = File.open(out_file, 'w+')
  #   end
  #   er = Erubis::Eruby.new(contents, :pattern => pat)
  #   of.write(er.result)
  #   of.close
  #   out_file
  # end
