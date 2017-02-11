require 'spec_helper'

module ErbTeX
  describe CommandLine do
    describe 'parsing' do
      before :all do
        @argv_with_file =
          %w(
            erbtex -draftmode -enc -etex -file-line-error -fmt junk
            -halt-on-error -ini -interaction batchmode -ipc -ipc-start
            -jobname junk -kpathsea-debug 8 -mktex tex --invoke=pdflatex
            -mltex -nomktex tfm -ouptput-comment This\ is\ a\ long\ comment
            -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
            -recorder -shell-escape -src-specials cr,display,hbox,math,par
            -translate-file willy -version &myformat file_name.tex.erb
          )
        @argv_with_cmds =
          %w(
            erbtex -draftmode -enc -etex -file-line-error -fmt junk
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
            erbtex -draftmode -enc -etex -file-line-error -fmt junk
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

      before :all do
      end

      after :all do
      end

      end

      end

      end

      end

      end
    end
  end
end
