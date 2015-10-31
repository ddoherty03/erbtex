require 'spec_helper'
#require 'file_utils'

module ErbTeX
  describe CommandLine do

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
