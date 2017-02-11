require 'spec_helper'

module ErbTeX
  describe CommandLine do
    describe 'parsing components' do
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
      end

      it 'should be able to parse command line with file name' do
        cl = CommandLine.new(@argv_with_file)
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to eq('file_name.tex.erb')
        expect(cl.tex_command).to eq(<<~'EOS'.tr("\n", ' ').strip)
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex -mltex -nomktex tfm
          -ouptput-comment This\ is\ a\ long\ comment
          -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version \&myformat file_name.tex
        EOS
      end

      it 'should be able to parse command line with TeX commands' do
        cl = CommandLine.new(@argv_with_cmds)
        expect(cl.tex_program).to eq('pdflatex')
        expect(cl.input_file).to be_nil
        expect(cl.tex_command).to eq(<<~'EOS')
          pdflatex -draftmode -enc -etex -file-line-error -fmt junk -halt-on-error
          -ini -interaction batchmode -ipc -ipc-start -jobname junk -kpathsea-debug 8
          -mktex tex --invoke=pdflatex -mltex -nomktex tfm
          -ouptput-comment "This is a long comment"
          -output-directory ~/texmf/tex -parse-first-line -progname pdflatex
          -recorder -shell-escape -src-specials cr,display,hbox,math,par
          -translate-file willy -version &myformat
          \\input{junk.tex} \\print these \\items \\end not_a_file)
        EOS
      end
    end

    describe 'old method' do
      before :all do
        @file_name = 'junk-with-hyphen.tex'
        FileUtils.touch(@file_name)
      end

      after :all do
        FileUtils.rm_f(@file_name)
      end

      it 'should be able to initialize from string' do
        cl = CommandLine.new("erbtex #{@file_name}")
        expect(cl.command_line).to eq "erbtex #{@file_name}"
      end

      it 'should be able to extract the program name' do
        cl = CommandLine.new("erbtex #{@file_name}")
        expect(cl.progname).to eq 'erbtex'
        expect(cl.input_file).to eq @file_name
      end

      it 'should be able to extract the input name ending in .tex' do
        names = [ 'junk-name.tex', 'junk.tex', '../junk.tex',
                  '/home/ded/junk.tex', 'junk_text.tex']
        names.each do |nm|
          FileUtils.touch(nm)
          cl = CommandLine.new("erbtex #{nm}")
          expect(cl.input_file).to eq nm
          FileUtils.rm_f(nm)
        end
      end

      it 'should be able to extract the input name ending in .tex.erb' do
        names = [ 'junk-name.tex.erb', 'junk.tex.erb', '../junk.tex.erb',
                  '/home/ded/junk.tex.erb', 'junk_text.tex.erb']
        names.each do |nm|
          FileUtils.touch(nm)
          cl = CommandLine.new("erbtex #{nm}")
          expect(cl.input_file).to eq nm
          FileUtils.rm_f(nm)
        end
      end

      it 'should be able to extract the input name not ending in .tex' do
        names = [ 'junk-name', 'junk', '../junk',
                  '/home/ded/junk', 'junk_text']
        # It should add the .tex prefix if not given on command line
        names.each do |nm|
          FileUtils.touch("#{nm}.tex")
          cl = CommandLine.new("erbtex #{nm}")
          expect(cl.input_file).to eq "#{nm}.tex"
          FileUtils.rm_f("#{nm}.tex")
        end
      end
    end
  end
end
