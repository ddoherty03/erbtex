# frozen_string_literal: true

require 'spec_helper'

module ErbTeX
  describe CommandLine do
    describe 'erbtex options' do
      it 'recognizes preprocess-only and removes it from TeX arguments' do
        cl = described_class.new(['--preprocess-only', 'file.tex'])

        expect(cl.preprocess_only).to be(true)
        expect(cl.tex_command).to eq(['pdflatex', 'file.tex'])
      end

      it 'accepts hyphenated executable names without truncating them' do
        cl = described_class.new(['--invoke=pdf-latex', 'file.tex'])

        expect(cl.tex_command).to eq(['pdf-latex', 'file.tex'])
      end

      it 'accepts executable paths containing spaces and punctuation' do
        cl = described_class.new(['--invoke=/opt/TeX tools/pdf-latex', 'file.tex'])

        expect(cl.tex_command).to eq(['/opt/TeX tools/pdf-latex', 'file.tex'])
      end

      it 'keeps the first invoke option when several are supplied' do
        cl = described_class.new(['--invoke=pdf-latex', '--invoke=lualatex', 'file.tex'])

        expect(cl.tex_command).to eq(['pdf-latex', 'file.tex'])
      end

      it 'rejects an empty executable name' do
        expect { described_class.new(['--invoke=', 'file.tex']) }
          .to raise_error(ArgumentError, '--invoke requires a nonempty executable name')
      end

      it 'recognizes exact informational flags and removes them from TeX arguments' do
        cl = described_class.new(['--help', '--version', '--help', 'file.tex'])

        expect(cl.print_help).to be(true)
        expect(cl.print_version).to be(true)
        expect(cl.tex_command).to eq(['pdflatex', 'file.tex'])
      end

      it 'passes options with similar prefixes through to TeX unchanged' do
        options = [
          '--helpful',
          '--help=extra',
          '--version-extra',
          '--version=extra',
          '--invoker=tex',
          '--preprocess-only=extra'
        ]
        cl = described_class.new([*options, 'file.tex'])

        expect(cl.print_help).to be(false)
        expect(cl.print_version).to be(false)
        expect(cl.preprocess_only).to be(false)
        expect(cl.tex_command).to eq(['pdflatex', *options, 'file.tex'])
      end

      it 'preserves option-like text after the first TeX command' do
        commands = ['\\relax', '--help', '--version', '--preprocess-only', '--invoke=other', '\\end']
        cl = described_class.new(['--invoke=pdf-latex', *commands])

        expect(cl.print_help).to be(false)
        expect(cl.print_version).to be(false)
        expect(cl.preprocess_only).to be(false)
        expect(cl.tex_command).to eq(['pdf-latex', *commands])
      end
    end

    describe 'parsing' do
      before do
        # Without this fakery, $0 would be rspec when these specs are run.
        $0 = 'erbtex'
        # NOTE: ARGV does not include the name of the program as the first
        # element, as in C.
        @argv_with_file =
          [
            '-draftmode',
            '-enc',
            '-etex',
            '-file-line-error',
            '-fmt',
            'junk',
            '-halt-on-error',
            '-ini',
            '-interaction',
            'batchmode',
            '-ipc',
            '-ipc-start',
            '-jobname',
            'junk',
            '-kpathsea-debug',
            '8',
            '-mktex',
            'tex',
            '--invoke=pdflatex',
            '-mltex',
            '-nomktex',
            'tfm',
            '-ouptput-comment',
            'This is a long comment',
            '-output-directory',
            '~/texmf/tex',
            '-parse-first-line',
            '-progname',
            'pdflatex',
            '-recorder',
            '-shell-escape',
            '-src-specials',
            'cr,display,hbox,math,par',
            '-translate-file',
            'willy',
            '-version',
            '&myformat',
            'file_name.tex.erb'
          ]
        @argv_with_remote_file =
          [
            '-draftmode',
            '-enc',
            '-etex',
            '-file-line-error',
            '-fmt',
            'junk',
            '-halt-on-error',
            '-ini',
            '-interaction',
            'batchmode',
            '-ipc',
            '-ipc-start',
            '-jobname',
            'junk',
            '-kpathsea-debug',
            '8',
            '-mktex',
            'tex',
            '--invoke=pdflatex',
            '-mltex',
            '-nomktex',
            'tfm',
            '-ouptput-comment',
            'This is a long comment',
            '-output-directory',
            '~/texmf/tex',
            '-parse-first-line',
            '-progname',
            'pdflatex',
            '-recorder',
            '-shell-escape',
            '-src-specials',
            'cr,display,hbox,math,par',
            '-translate-file',
            'willy',
            '-version',
            '&myformat',
            'example_files/file_name.tex.erb'
          ]
        @argv_with_invoke_and_file =
          [
            '--invoke=lualatex',
            '-draftmode',
            '-enc',
            '-etex',
            '-file-line-error',
            '-fmt',
            'junk',
            '-halt-on-error',
            '-ini',
            '-interaction',
            'batchmode',
            '-ipc',
            '-ipc-start',
            '-jobname',
            'junk',
            '-kpathsea-debug',
            '8',
            '-mktex',
            'tex',
            '--invoke=pdflatex',
            '-mltex',
            '-nomktex',
            'tfm',
            '-ouptput-comment',
            'This is a long comment',
            '-output-directory',
            '~/texmf/tex',
            '-parse-first-line',
            '-progname',
            'pdflatex',
            '-recorder',
            '-shell-escape',
            '-src-specials',
            'cr,display,hbox,math,par',
            '-translate-file',
            'willy',
            '-version',
            '&myformat',
            'file_name.tex.erb'
          ]
        @argv_with_cmds =
          [
            '-draftmode',
            '-enc',
            '-etex',
            '-file-line-error',
            '-fmt',
            'junk',
            '-halt-on-error',
            '-ini',
            '-interaction',
            'batchmode',
            '-ipc',
            '-ipc-start',
            '-jobname',
            'junk',
            '-kpathsea-debug',
            '8',
            '-mktex',
            'tex',
            '--invoke=pdflatex',
            '-mltex',
            '-nomktex',
            'tfm',
            '-ouptput-comment',
            'This is a long comment',
            '-output-directory',
            '~/texmf/tex',
            '-parse-first-line',
            '-progname',
            'pdflatex',
            '-recorder',
            '-shell-escape',
            '-src-specials',
            'cr,display,hbox,math,par',
            '-translate-file',
            'willy',
            '-version',
            '&myformat',
            '\\input{junk.tex}',
            '\\print',
            'these',
            '\\items',
            '\\end',
            'not_a_file'
          ]
        @argv_with_file_cmds =
          [
            '-draftmode',
            '-enc',
            '-etex',
            '-file-line-error',
            '-fmt',
            'junk',
            '-halt-on-error',
            '-ini',
            '-interaction',
            'batchmode',
            '-ipc',
            '-ipc-start',
            '-jobname',
            'junk',
            '-kpathsea-debug',
            '8',
            '-mktex',
            'tex',
            '--invoke=pdflatex',
            '-mltex',
            '-nomktex',
            'tfm',
            '-ouptput-comment',
            'This is a long comment',
            '-output-directory',
            '~/texmf/tex',
            '-parse-first-line',
            '-progname',
            'pdflatex',
            '-recorder',
            '-shell-escape',
            '-src-specials',
            'cr,display,hbox,math,par',
            '-translate-file',
            'willy',
            '-version',
            '&myformat',
            'file_name',
            '\\input{junk.tex}',
            '\\print',
            'these',
            '\\items',
            '\\end',
            'not_a_file'
          ]
      end

      it 'parse command line with file name' do
        cl = CommandLine.new(@argv_with_file)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to eq('file_name.tex.erb')
        expect(cl.tex_command).to eq(Shellwords.split(<<~'EOS'))
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat file_name.tex.erb
        EOS
      end

      it 'parse command line with remote file name' do
        cl = CommandLine.new(@argv_with_remote_file)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to eq('example_files/file_name.tex.erb')
        expect(cl.tex_command).to eq(Shellwords.split(<<~'EOS'))
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat example_files/file_name.tex.erb
        EOS
      end

      it 'parse command line with invoke and file name' do
        cl = CommandLine.new(@argv_with_invoke_and_file)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('lualatex')
        expect(cl.input_file).to eq('file_name.tex.erb')
        expect(cl.tex_command).to eq(Shellwords.split(<<~'EOS'))
          lualatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat file_name.tex.erb
        EOS
      end

      it 'parse command line with TeX commands' do
        cl = CommandLine.new(@argv_with_cmds)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to be_nil
        expect(cl.tex_command).to eq(Shellwords.split(<<~'EOS'))
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat
          \\input\{junk.tex\} \\print these \\items \\end not_a_file
        EOS
      end

      it 'parse command line with a file name and TeX commands' do
        cl = CommandLine.new(@argv_with_file_cmds)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to eq('file_name')
        expect(cl.tex_command).to eq(Shellwords.split(<<~'EOS'))
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat
          file_name
          \\input\{junk.tex\} \\print these \\items \\end not_a_file
        EOS
      end
    end
  end
end
