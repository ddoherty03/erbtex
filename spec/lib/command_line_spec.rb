require 'spec_helper'

module ErbTeX
  describe CommandLine do
    describe 'parsing' do
      before :all do
        # Without this fakery, $0 would be rspec when these specs are run.
        $0 = 'erbtex'
        # Note: ARGV does not include the name of the program as the first
        # element, as in C.
        @argv_with_file =
          %w(
            -draftmode -enc -etex -file-line-error -fmt junk
            -halt-on-error -ini -interaction batchmode -ipc -ipc-start
            -jobname junk -kpathsea-debug 8 -mktex tex --invoke=pdflatex
            -mltex -nomktex tfm -ouptput-comment This\ is\ a\ long\ comment
            -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
            -recorder -shell-escape -src-specials cr,display,hbox,math,par
            -translate-file willy -version &myformat file_name.tex.erb
          )
        @argv_with_invoke_and_file =
          %w(
            --invoke=lualatex
            -draftmode -enc -etex -file-line-error -fmt junk
            -halt-on-error -ini -interaction batchmode -ipc -ipc-start
            -jobname junk -kpathsea-debug 8 -mktex tex --invoke=pdflatex
            -mltex -nomktex tfm -ouptput-comment This\ is\ a\ long\ comment
            -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
            -recorder -shell-escape -src-specials cr,display,hbox,math,par
            -translate-file willy -version &myformat file_name.tex.erb
          )
        @argv_with_cmds =
          %w(
            -draftmode -enc -etex -file-line-error -fmt junk
            -halt-on-error -ini -interaction batchmode -ipc -ipc-start
            -jobname junk -kpathsea-debug 8 -mktex tex --invoke=pdflatex
            -mltex -nomktex tfm -ouptput-comment This\ is\ a\ long\ comment
            -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
            -recorder -shell-escape -src-specials cr,display,hbox,math,par
            -translate-file willy -version &myformat
            \\input{junk.tex} \\print these \\items \\end not_a_file
          )
        @argv_with_file_cmds =
          %w(
            -draftmode -enc -etex -file-line-error -fmt junk
            -halt-on-error -ini -interaction batchmode -ipc -ipc-start
            -jobname junk -kpathsea-debug 8 -mktex tex --invoke=pdflatex
            -mltex -nomktex tfm -ouptput-comment This\ is\ a\ long\ comment
            -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
            -recorder -shell-escape -src-specials cr,display,hbox,math,par
            -translate-file willy -version &myformat file_name
            \\input{junk.tex} \\print these \\items \\end not_a_file
          )
      end

      it 'parse command line with file name' do
        cl = CommandLine.new(@argv_with_file)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to eq('file_name.tex.erb')
        expect(cl.tex_command).to eq(<<~'EOS'.tr("\n", ' ').strip)
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat file_name.tex.erb
        EOS
      end

      it 'parse command line with invoke and file name' do
        cl = CommandLine.new(@argv_with_invoke_and_file)
        expect(cl.erbtex_name).to eq('erbtex')
        expect(cl.tex_program).to eq('lualatex')
        expect(cl.input_file).to eq('file_name.tex.erb')
        expect(cl.tex_command).to eq(<<~'EOS'.tr("\n", ' ').strip)
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
        expect(cl.tex_command).to eq(<<~'EOS'.tr("\n", ' ').strip)
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
        expect(cl.tex_command).to eq(<<~'EOS'.tr("\n", ' ').strip)
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory \~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat
          \\input\{junk.tex\} \\print these \\items \\end not_a_file
          file_name
        EOS
      end
    end

    describe 'expand input file' do
      before :all do
        unless Dir.exist?('tmp')
          FileUtils.mkdir_p('tmp')
        end
      end

      before :each do
        FileUtils.rm_f Dir.glob('tmp/*')
      end

      after :all do
        FileUtils.rm_rf('tmp')
      end

      it 'expand file name with no extension and .tex existing' do
        FileUtils.touch('tmp/junk.tex')
        expect(CommandLine.expand_input_file('tmp/junk')).to eq('tmp/junk.tex')
      end

      it 'expand file name with no extension and .tex.erb existing' do
        FileUtils.touch('tmp/junk.tex.erb')
        expect(CommandLine.expand_input_file('tmp/junk'))
          .to eq('tmp/junk.tex.erb')
      end

      it 'expand file name with no extension and .erb existing' do
        FileUtils.touch('tmp/junk.erb')
        expect(CommandLine.expand_input_file('tmp/junk'))
          .to eq('tmp/junk.erb')
      end

      it 'expand file name with .tex extension and existing' do
        FileUtils.touch('tmp/junk.tex')
        expect(CommandLine.expand_input_file('tmp/junk'))
          .to eq('tmp/junk.tex')
      end

      it 'expand file name with .tex extension and not existing' do
        expect(CommandLine.expand_input_file('tmp/junk.tex'))
          .to eq('tmp/junk.tex')
      end

      it 'expand file name with funny extension and not existing' do
        expect(CommandLine.expand_input_file('tmp/junk.arb'))
          .to eq('tmp/junk.arb')
      end
    end
  end
end
