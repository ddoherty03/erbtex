# -*- coding: utf-8 -*-

module ErbTeX
  class NoInputFile < StandardError; end

  class CommandLine
    attr_reader :command_line, :marked_command_line, :input_file
    attr_reader :progname, :input_path, :output_dir, :run_dir

    def initialize(command_line)
      @command_line = command_line
      @input_file = @marked_command_line = nil
      @run_dir = Dir.pwd
      find_output_dir
      find_progname
      find_input_file
      find_input_path
      mark_command_line
    end

    def find_progname
      @progname = @command_line.split(' ')[0]
    end

    def find_output_dir
      args = @command_line.split(' ')
      # There is an -output-comment option, so -output-d is the shortest
      # unambiguous way to write the -output-directory option.  It can use
      # one or two dashes at the beginning, and the argument can be
      # seaparated from it with an '=' or white space.
      have_out_dir = false
      out_dir = nil
      args.each do |a|
        if have_out_dir
          # Found -output-directory on last pass without an equals sign
          out_dir = a
        end
        if a =~ /^--?output-d(irectory)?=(\S+)/
          out_dir = $2
        elsif a =~ /^--?output-d(irectory)?$/
          # Next arg is the out_dir
          have_out_dir = true
        end
      end
      if out_dir.nil?
        if File.writable?(Dir.pwd)
          @output_dir = Dir.pwd
        else
          @output_dir = File.expand_path(ENV['TEXMFOUTPUT'])
        end
      else
        @output_dir = File.expand_path(out_dir)
      end
    end

    def find_input_file
      # Remove the initial command from the command line
      cmd = @command_line.split(/\s+/)[1..-1].join(' ')
      # Strip out options
      cmd = cmd.gsub(/\s+--?[-\w]+(=[-\w]+)?/, ' ')
      infile_re = %r{(\\input\s+)?(([-.~_/A-Za-z0-9]+)(\.[a-z]+)?)\s*$}
      if cmd =~ infile_re
        @input_file = "#{$2}"
        if @input_file =~ /\.tex(\.erb)?$/
          @input_file = @input_file
        else
          @input_file += ".tex"
        end
      elsif cmd =~ %r{(\\input\s+)?(["'])((?:\\?.)*?)\2} #"
        # The re above captures single- or double-quoted strings with
        # the insides in $3
        @input_file = "#{$3}"
        if @input_file !~ /\.tex$/
          @input_file += ".tex#{$1}"
        end
      else
        @input_file = nil
      end
    end

    def find_input_path
      # If input_file is absolute, don't look further
      if @input_file =~ /^\//
        @input_path = @input_file
      elsif @input_file.nil?
        @input_path = nil
      else
        # The following cribbed from kpathsea.rb
        @progname.untaint
        @input_file.untaint
        kpsewhich = "kpsewhich -progname=\"#{@progname}\" -format=\"tex\" \"#{@input_file}\""
        lines = []
        IO.popen(kpsewhich) do |io|
          lines = io.readlines
        end
        if $? == 0
          if lines.empty?
            @input_path = nil
          else
            @input_path = lines[0].chomp.untaint
          end
        else
          raise NoInputFile, "Can't find #{@input_file} in TeX search path; try kpsewhich -format=tex #{@input_file}."
        end
      end
    end

    def new_command_line(new_progname, new_infile)
      ncl = @marked_command_line.sub('^p^', new_progname)
      # Quote the new_infile in case it has spaces
      if new_infile
        ncl = ncl.sub('^f^', "'#{new_infile}'")
      end
      ncl
    end

    def mark_command_line
      # Replace input file with '^f^'
      infile_re = %r{(\\input\s+)?(([-.~_/A-Za-z0-9]+)(\.[a-z]+)?)\s*$}
      quoted_infile_re = %r{(\\input\s+)?(["'])((?:\\?.)*?)\2} #"
      if @input_file.nil?
        @marked_command_line = @command_line
      elsif @command_line =~ infile_re
        @marked_command_line = @command_line.sub(infile_re, "#{$1}^f^")
      elsif @command_line =~ quoted_infile_re
        @marked_command_line = @command_line.sub(quoted_infile_re, "#{$1}^f^")
      else
        @marked_command_line = @command_line
      end
      # Replace progname with '^p^'
      @marked_command_line = @marked_command_line.lstrip
      @marked_command_line = @marked_command_line.sub(/\S+/, '^p^')
    end
  end
end

# NOTES:

# The following text is from the Web2C documentation at
# http://tug.org/texinfohtml/web2c.html#Output-file-location
#
# 3.4 Output file location
#
# All the programs generally follow the usual convention for output
# files. Namely, they are placed in the directory current when the
# program is run, regardless of any input file location; or, in a few
# cases, output is to standard output.

# For example, if you run ‘tex /tmp/foo’, for example, the output will
# be in ./foo.dvi and ./foo.log, not /tmp/foo.dvi and /tmp/foo.log.

# You can use the ‘-output-directory’ option to cause all output files
# that would normally be written in the current directory to be written
# in the specified directory instead. See Common options.

# If the current directory is not writable, and ‘-output-directory’ is
# not specified, the main programs (TeX, Metafont, MetaPost, and BibTeX)
# make an exception: if the config file or environment variable value
# TEXMFOUTPUT is set (it is not by default), output files are written to
# the directory specified.

# TEXMFOUTPUT is also checked for input files, as TeX often generates
# files that need to be subsequently read; for input, no suffixes (such
# as ‘.tex’) are added by default and no exhaustive path searching is
# done, the input name is simply checked as given.
