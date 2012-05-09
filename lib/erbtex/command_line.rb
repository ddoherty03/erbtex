# -*- coding: utf-8 -*-
module ErbTeX
  class CommandLine
    attr_reader :command_line, :marked_command_line, :input_file
    attr_reader :progname, :input_path, :output_dir
    
    def initialize(command_line)
      @command_line = command_line
      @input_file = @marked_command_line = nil
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
      infile_re = %r{(\\input\s+)?(([-_/A-Za-z0-9]+)(\.[a-z]+)?)\s*$}
      if @command_line =~ infile_re
        @input_file = "#{$2}"
        if @input_file !~ /\.tex$/
          @input_file += ".tex"
        end          
      elsif @command_line =~ %r{(\\input\s+)?(["'])((?:\\?.)*?)\2} #"
        # The re above captures single- or double-quoted strings with
        # the insides in $3
        @input_file = "#{$3}"
        if @input_file !~ /\.tex$/
          @input_file += ".tex"
        end          
      else
        raise "Can't find input file in #{@command_line}"
      end
    end

    def find_input_path
      # The following cribbed from kpathsea.rb
      @progname.untaint
      @input_file.untaint
      kpsewhich = "kpsewhich -progname=\"#{@progname}\" -format=\"tex\" #{@input_file}"
      lines = ""
      IO.popen(kpsewhich) do |io|
        lines = io.readlines
      end
      @input_path = ($? == 0 ? lines[0].chomp.untaint : nil)
    end
    
    def mark_command_line
      infile_re = %r{(\\input\s+)?(([-_A-Za-z0-9]+)(\.[a-z]+)?)\s*$}
      if @command_line =~ infile_re
        @marked_command_line = @command_line.sub(infile_re, "#{$1}^f^")
      end
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
