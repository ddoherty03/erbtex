require 'spec_helper'

module ErbTeX
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
      expect(ErbTeX.expand_input_file('tmp/junk')).to eq('tmp/junk.tex')
    end

    it 'expand file name with no extension and .tex.erb existing' do
      FileUtils.touch('tmp/junk.tex.erb')
      expect(ErbTeX.expand_input_file('tmp/junk'))
        .to eq('tmp/junk.tex.erb')
    end

    it 'expand file name with no extension and .erb existing' do
      FileUtils.touch('tmp/junk.erb')
      expect(ErbTeX.expand_input_file('tmp/junk'))
        .to eq('tmp/junk.erb')
    end

    it 'expand file name with no extension and .tex existing' do
      FileUtils.touch('tmp/junk.tex')
      expect(ErbTeX.expand_input_file('tmp/junk'))
        .to eq('tmp/junk.tex')
    end

    it 'expand file name with .tex extension and .tex existing' do
      FileUtils.touch('tmp/junk.tex')
      expect(ErbTeX.expand_input_file('tmp/junk.tex'))
        .to eq('tmp/junk.tex')
    end

    it 'expand file name with .tex extension and not existing' do
      FileUtils.rm_rf('tmp/junk.tex') if File.exist?('tmp/junk.tex')
      expect(ErbTeX.expand_input_file('tmp/junk.tex'))
        .to eq('tmp/junk.tex')
    end

    it 'expand file name with funny extension and not existing' do
      expect(ErbTeX.expand_input_file('tmp/junk.arb'))
        .to eq('tmp/junk.arb')
    end
  end
end
