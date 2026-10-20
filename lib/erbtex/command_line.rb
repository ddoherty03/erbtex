# frozen_string_literal: true

# Name space for erbtex command.
module ErbTeX
  class NoInputFile < StandardError; end

  # Class to record and manipulate the command line typed by the user.
  class CommandLine
    attr_reader :erbtex_name, :tex_program, :tex_args, :tex_commands, :input_file, :print_version, :print_help
    attr_reader :preprocess_only

    def initialize(argv)
      # Arguments have already been split by the shell. Preserve each string
      # unchanged and pass it directly to the TeX process.

      @erbtex_name = File.basename($PROGRAM_NAME)

      # Find the tex_commands
      @tex_commands = []
      if argv.any? { |a| a.start_with?('\\') }
        # All args after first starting with '\' should be interpreted as TeX
        # commands, even if they don't start with '\'
        @tex_commands = argv.drop_while { |a| a !~ /\A\\/ }
        first_tex_command_k = argv.size - @tex_commands.size
        argv = argv.take(first_tex_command_k)
      end

      # Keep the complete executable name, including paths and punctuation.
      invoke_options = argv.select { |argument| argument.start_with?('--invoke=') }
      if invoke_options.include?('--invoke=')
        raise ArgumentError, '--invoke requires a nonempty executable name'
      end

      @tex_program = invoke_options.first&.delete_prefix('--invoke=') || 'pdflatex'
      argv = argv.reject { |argument| argument.start_with?('--invoke=') }

      @print_version = argv.include?('--version')
      @print_help = argv.include?('--help')
      @preprocess_only = argv.include?('--preprocess-only')
      argv = argv.reject { |argument| argument == '--version' || argument == '--help' }
      argv = argv.reject { |argument| argument == '--preprocess-only' }

      # The last argument, assuming it does not start with a '-' or '&', is
      # assumed to be the name of the input_file.
      @input_file = nil
      @input_file = ErbTeX.expand_input_file(argv.pop) if !argv.empty? && argv[-1] !~ /\A[-&]/

      # What remains in argv should be the tex program's '-options', which
      # should be passed through untouched. So, can form the full command line
      # for tex_processing
      @tex_args = argv.dup
    end

    def tex_command(tex_file = input_file)
      [tex_program, *tex_args, tex_file, *tex_commands].compact
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
