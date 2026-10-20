# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'rbconfig'
require 'tmpdir'

describe ErbTeX do
  describe '.erb_to_tex' do
    before do
      allow(described_class).to receive(:warn)
    end

    around do |example|
      Dir.mktmpdir('erbtex-spec') do |directory|
        Dir.chdir(directory) { example.run }
      end
    end

    it 'preserves existing output when the template has a syntax error' do
      File.write('file.tex.erb', '{: if :}')
      File.write('file.tex', 'previous output')

      expect { described_class.erb_to_tex('file.tex.erb', '') }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
      expect(File.read('file.tex')).to eq('previous output')
      expect(Dir.children('.')).to contain_exactly('file.tex.erb', 'file.tex')
    end

    it 'preserves existing output when the template raises an exception' do
      File.write('file.tex.erb', '{: raise "template failed" :}')
      File.write('file.tex', 'previous output')

      expect { described_class.erb_to_tex('file.tex.erb', '') }
        .to raise_error(RuntimeError, 'template failed')
      expect(File.read('file.tex')).to eq('previous output')
      expect(Dir.children('.')).to contain_exactly('file.tex.erb', 'file.tex')
    end

    it 'replaces existing output after rendering successfully and removes the temporary file' do
      File.write('file.tex.erb', 'answer: {:= 6 * 7 :}')
      File.write('file.tex', 'previous output')

      expect(described_class.erb_to_tex('file.tex.erb', '')).to eq('file.tex')
      expect(File.read('file.tex')).to eq('answer: 42')
      expect(File.read('file.tex.erb')).to eq('answer: {:= 6 * 7 :}')
      expect(Dir.children('.')).to contain_exactly('file.tex.erb', 'file.tex')
    end
  end

  def run_erbtex(flag)
    root = File.expand_path('../..', __dir__)
    Open3.capture3(
      RbConfig.ruby,
      "-I#{File.join(root, 'lib')}",
      File.join(root, 'bin', 'erbtex'),
      flag,
    )
  end

  it 'prints help and exits successfully without processing a file' do
    stdout, stderr, status = run_erbtex('--help')

    expect(status.exitstatus).to eq(0), stderr
    expect(stdout).to include('Usage: erbtex')
    expect(stderr).to eq('')
  end

  it 'prints version information and exits successfully without processing a file' do
    stdout, stderr, status = run_erbtex('--version')

    expect(status.exitstatus).to eq(0), stderr
    expect(stdout).to include("erbtex version: #{ErbTeX::VERSION}", 'Ruby version:', 'erubis version:')
    expect(stderr).to eq('')
  end
end
