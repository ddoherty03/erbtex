require 'test_helper'

class FindBinaryTest < Minitest::Test
  include ErbTeX

  # Here we set up the situation as we expect it to be after
  # installation.  There is a "real" pdflatex executable binary and
  # there is one that is just a link to our script, the "fake" binary.
  # The fake binary is earlier in PATH than the real binary, and we want
  # this function, when fed the name of the fake binary to deduce the
  # name of the real binary.
  def setup
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

  def teardown
    FileUtils.rm_rf(@fake_dir)
  end

  def test_find_pdflatex
    assert_equal(@real_binary,
                 ErbTeX.find_executable(@fake_binary))
  end

  def test_find_pdflatex_with_erbtex
    assert_equal(@real_binary,
                 ErbTeX.find_executable(@erbtex))
  end
end
