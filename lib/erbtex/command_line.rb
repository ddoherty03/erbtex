# coding: utf-8

# Name space for erbtex command.
module ErbTeX
  class NoInputFile < StandardError; end

  # Class to record and manipulate the command line typed by the user.
  class CommandLine
    attr_reader :erbtex_name, :tex_program, :tex_args, :tex_commands
    attr_reader :input_file, :print_version, :print_help

    def initialize(argv)
      # Note: argv will be the command line arguments after processing by the
      # shell, so if we see things such as '&', '~', '\' in the args, these
      # were quoted by the user on the command-line and need no special
      # treatment here. For example, '~/junk' on the commandline will show up
      # here as '/home/ded/junk'. If we see '~/junk', that means the user has
      # quoted the ~ on the command line with something like '\~junk', so we
      # should assume that the user wants to keep it that way. Likewise, an
      # arg with spaces in it will have been quoted by the user to be seen as
      # a single argument.  When we output these for use by the shell in the
      # system command, we should apply shellquote to everything so that the
      # receiving shell sees the args in the same way.

      @erbtex_name = File.basename($PROGRAM_NAME)

      # Find the tex_commands
      @tex_commands = []
      if argv.any? { |a| a =~ /\A\\/ }
        # All args after first starting with '\' should be interpreted as TeX
        # commands, even if they don't start with '\'
        @tex_commands = argv.drop_while { |a| a !~ /\A\\/ }
        first_tex_command_k = argv.size - @tex_commands.size
        argv = argv[0..first_tex_command_k - 1]
      end

      # Look for our --invoke=tex_command option
      @tex_program = 'pdflatex'
      if argv.any? { |a| a =~ /\A--invoke=(\w+)/ }
        @tex_program = $1
        argv.reject! { |a| a =~ /\A--invoke=(\w+)/ }
      end

      # Look for our --version
      @print_version = false
      if argv.any? { |a| a =~ /\A--version/ }
        @print_version = true
        argv.reject! { |a| a =~ /\A--version/ }
      end

      # Look for our --help
      @print_help = false
      if argv.any? { |a| a =~ /\A--help/ }
        @print_help = true
        argv.reject! { |a| a =~ /\A--help/ }
      end

      # The last argument, assuming it does not start with a '-' or '&', is
      # assumed to be the name of the input_file.
      @input_file = nil
      if !argv.empty? && argv[-1] !~ /\A[-&]/
        @input_file = CommandLine.expand_input_file(argv.pop)
      end

      # What remains in argv should be the tex program's '-options', which
      # should be passed through untouched. So, can form the full command line
      # for tex_processing
      @tex_args = argv.dup
    end

    def tex_command(tex_file = input_file)
      "#{tex_program} " \
      "#{tex_args.shelljoin} " \
      "#{tex_commands.shelljoin} " \
      "#{tex_file}"
        .strip.squeeze(' ')
    end

    # Return the name of the input file based on the name given in the command
    # line. Try to find the right extension for the input file if none is given.
    def self.expand_input_file(input_file)
      return '' if input_file.blank?

      md = %r{\A(.*)(\.[\w.]+)?\z}.match(input_file)
      if md
        input_base = md[1]
        input_ext = md[2]
      end
      if input_ext.nil?
        if File.exist?("#{input_base}.tex.erb")
          "#{input_base}.tex.erb"
        elsif File.exist?("#{input_base}.tex")
          "#{input_base}.tex"
        elsif File.exist?("#{input_base}.erb")
          "#{input_base}.erb"
        else
          input_base
        end
      else
        input_base
      end
    end
  end
end

# NOTES:
# The following text is from the Web2C documentation at
# http://tug.org/texinfohtml/web2c.html#Output-file-location
#
# 4.1 TeX invocation
#
#   TeX, Metafont, and MetaPost process the command line (described here)
#   and determine their memory dump (fmt) file in the same way (*note Memory
#   dumps::).  Synopses:
#
#   tex [OPTION]... [TEXNAME[.tex]] [TEX-COMMANDS]
#   tex [OPTION]... \FIRST-LINE
#   tex [OPTION]... &FMT ARGS
#
#   TeX searches the usual places for the main input file TEXNAME (*note
#   (kpathsea)Supported file formats::), extending TEXNAME with '.tex' if
#   necessary.  To see all the relevant paths, set the environment variable
#   'KPATHSEA_DEBUG' to '-1' before running the program.
#
#   After TEXNAME is read, TeX processes any remaining TEX-COMMANDS on
#   the command line as regular TeX input.  Also, if the first non-option
#   argument begins with a TeX escape character (usually '\'), TeX processes
#   all non-option command-line arguments as a line of regular TeX input.

# 3.4 Output file location
#
# All the programs generally follow the usual convention for output
# files. Namely, they are placed in the directory current when the
# program is run, regardless of any input file location; or, in a few
# cases, output is to standard output.

# For example, if you run 'tex /tmp/foo', for example, the output will
# be in ./foo.dvi and ./foo.log, not /tmp/foo.dvi and /tmp/foo.log.

# You can use the '-output-directory' option to cause all output files
# that would normally be written in the current directory to be written
# in the specified directory instead. See Common options.

# If the current directory is not writable, and '-output-directory' is
# not specified, the main programs (TeX, Metafont, MetaPost, and BibTeX)
# make an exception: if the config file or environment variable value
# TEXMFOUTPUT is set (it is not by default), output files are written to
# the directory specified.

# TEXMFOUTPUT is also checked for input files, as TeX often generates
# files that need to be subsequently read; for input, no suffixes (such
# as '.tex') are added by default and no exhaustive path searching is
# done, the input name is simply checked as given.
