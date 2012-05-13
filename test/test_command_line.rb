require './test_helper'

class CommandLineTest < Test::Unit::TestCase
  include ErbTeX
  
  def setup
    @test_dir = File.dirname(File.absolute_path(__FILE__))
    @junk_tex = @test_dir + '/junk.tex'
    FileUtils.touch(@junk_tex)
    
    @tex_dir = @test_dir + '/tex_dir'
    FileUtils.mkdir(@tex_dir) unless File.exists?(@tex_dir)
    @junk2_tex = @tex_dir + '/junk2.tex'
    FileUtils.touch(@junk2_tex)

    @tex_dir_nw = @test_dir + '/tex_dir_nw'
    FileUtils.mkdir(@tex_dir_nw) unless File.exists?(@tex_dir_nw)
    @junk3_tex = @tex_dir_nw + '/junk3.tex'
    FileUtils.touch(@junk3_tex)
    FileUtils.chmod(0500, @tex_dir_nw)
  end

  def teardown
    FileUtils.rm(@junk_tex)
    FileUtils.rm_rf(@tex_dir)
    FileUtils.chmod(0700, @tex_dir_nw)
    FileUtils.rm_rf(@tex_dir_nw)
  end
  
  def test_find_ordinary_input_file
    cl = 'pdflatex -ini --halt-on-error junk'
    assert_equal("junk.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_input_file_relative
    cl = 'pdflatex -ini --halt-on-error ./junk.tex'
    assert_equal("./junk.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_input_file_relative_no_ext
    cl = 'pdflatex -ini --halt-on-error ./junk'
    assert_equal("./junk.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_ordinary_input_file_with_ext
    cl = 'pdflatex -ini --halt-on-error junk.tex'
    assert_equal("junk.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_ordinary_input_file_with_spaces
    fn = 'A junk.tex'
    FileUtils.touch(fn)
    cl = "pdflatex -ini --halt-on-error \'#{fn}\'"
    assert_equal("A junk.tex",
           CommandLine.new(cl).input_file)
    FileUtils.rm(fn)
  end

  def test_no_input_file
    assert_raise ErbTeX::NoInputFile do
      cl = 'pdflatex -ini'
      CommandLine.new(cl)
    end
  end

  def test_no_input_file_with_eq
    assert_raise ErbTeX::NoInputFile do
      cl = 'pdflatex -ini -output-directory=/tmp'
      CommandLine.new(cl).input_file
    end
  end
  
  def test_find_progname
    cl = 'pdflatex -ini --halt-on-error junk.tex'
    assert_equal("pdflatex",
           CommandLine.new(cl).progname)
  end
  
  def test_mark_command_line
    cl = 'pdflatex -ini --halt-on-error junk'
    clm = '^p^ -ini --halt-on-error ^f^'
    assert_equal(clm,
           CommandLine.new(cl).marked_command_line)
  end
  
  def test_mark_command_line_with_ext
    cl = 'pdflatex -ini --halt-on-error junk.tex'
    clm = '^p^ -ini --halt-on-error ^f^'
    assert_equal(clm,
           CommandLine.new(cl).marked_command_line)
  end
  
  def test_mark_command_line_with_dir
    cl = 'pdflatex -ini --halt-on-error ~/junk.tex'
    clm = '^p^ -ini --halt-on-error ^f^'
    assert_equal(clm,
           CommandLine.new(cl).marked_command_line)
  end
  
  def test_mark_command_line_with_spaces
    cl = 'pdflatex -ini --halt-on-error \'/home/ded/A junk.tex\''
    clm = '^p^ -ini --halt-on-error ^f^'
    assert_equal(clm,
           CommandLine.new(cl).marked_command_line)
  end
  
  def test_find_embedded_input_file
    cl = 'pdflatex -ini --halt-on-error \input junk'
    assert_equal("junk.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_embedded_input_file_with_ext
    cl = 'pdflatex -ini --halt-on-error \input junk.tex'
    assert_equal("junk.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_input_file_with_relative
    cl = 'pdflatex -ini --halt-on-error \input tex_dir/junk2.tex'
    assert_equal("tex_dir/junk2.tex",
           CommandLine.new(cl).input_file)
  end

  def test_find_input_file_with_spaces
    fn = "my junk2.tex"
    FileUtils.touch(fn)
    cl = "pdflatex -ini --halt-on-error \input \"#{fn}\""
    assert_equal(fn,
                 CommandLine.new(cl).input_file)
    FileUtils.rm(fn)
  end

  def test_find_input_path_existing
    cl = 'pdflatex -ini --halt-on-error \input junk.tex'
    assert_equal("./junk.tex",
           CommandLine.new(cl).input_path)
  end

  def test_dont_find_input_path_non_existing
    cl = 'pdflatex -ini --halt-on-error \input junk3.tex'
    assert_raise NoInputFile do
      CommandLine.new(cl).input_path
    end
  end

  def test_find_full_path_with_env
    save_env = ENV['TEXINPUTS']
    ENV['TEXINPUTS'] = File.dirname(__FILE__) + '/tex_dir'
    cl = 'pdflatex -ini --halt-on-error \input junk2.tex'
    assert_equal("./tex_dir/junk2.tex",
           CommandLine.new(cl).input_path)
    ENV['TEXINPUTS'] = save_env
  end

  def test_find_output_dir
    cl = 'pdflatex -ini --halt-on-error \input junk.tex'
    assert_equal(File.expand_path('./'), CommandLine.new(cl).output_dir)
  end

  def test_find_output_dir_with_options
    cl = 'pdflatex -ini -output-d=~/tmp \input junk.tex'
    assert_equal(File.expand_path('~/tmp'), CommandLine.new(cl).output_dir)
  end

  def test_find_output_dir_with_non_writable_pwd
    cl = 'pdflatex -ini \input junk3.tex'
    ENV['TEXMFOUTPUT'] = File.expand_path(File.dirname(__FILE__) + '/tex_dir')
    Dir.chdir('tex_dir_nw') do
      assert_equal(File.expand_path('../tex_dir'), CommandLine.new(cl).output_dir)
    end
  end
end
