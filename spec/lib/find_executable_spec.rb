require 'spec_helper'

module ErbTeX
  describe 'FindExecutable' do
    # Here we set up the situation as we expect it to be after
    # installation.  There is a "real" pdflatex executable binary and
    # there is one that is just a link to our script, the "fake" binary.
    # The fake binary is earlier in PATH than the real binary, and we want
    # this function, when fed the name of the fake binary to deduce the
    # name of the real binary.
    before :all do
      # Create a "fake" ruby script named pdflatex
      @fake_dir = File.dirname(File.absolute_path(__FILE__)) + '/fake_bin'
      FileUtils.mkdir(@fake_dir) unless File.exist?(@fake_dir)
      @fake_binary = @fake_dir + '/pdflatex'
      @erbtex = @fake_dir + '/erbtex'
      FileUtils.touch(@erbtex)
      FileUtils.chmod(0700, @erbtex)
      FileUtils.rm_rf(@fake_binary) if File.exist?(@fake_binary)
      FileUtils.ln_s(@erbtex, @fake_binary)

      # Point to "real" pdflatex to find
      @real_binary = '/usr/bin/pdflatex'
      @real_dir = '/usr/bin'

      # Put the fake dir on the PATH before the real dir
      ENV['PATH'] = @fake_dir + ':' + @real_dir + ':' + ENV['PATH']
    end

    after :all do
      FileUtils.rm_rf(@fake_dir)
    end

    it 'should find the real executable from fake' do
      expect(ErbTeX.find_executable(@fake_binary)).to eq @real_binary
    end

    it 'should find the real executable from erbtex' do
      expect(ErbTeX.find_executable(@erbtex)).to eq @real_binary
    end

  end
end
