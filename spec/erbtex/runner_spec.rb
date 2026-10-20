# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require 'json'

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

    it 'reports the input path and line number for a template syntax error' do
      Dir.mkdir('templates')
      File.write('templates/my document.tex.erb', "first line\nsecond line\n{: ) :}\n")

      _, stderr, status = run_erbtex('templates/my document.tex.erb')

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include('Erubis pre-processing failed:', 'templates/my document.tex.erb:3')
    end

    it 'identifies the input path and line number in a template runtime backtrace' do
      Dir.mkdir('templates')
      File.write('templates/my document.tex.erb', "first line\nsecond line\n{: raise 'template failed' :}\n")

      _, stderr, status = run_erbtex('templates/my document.tex.erb')

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include('template failed', 'templates/my document.tex.erb:3')
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

  describe 'TeX invocation' do
    around do |example|
      Dir.mktmpdir('erbtex-invocation') do |directory|
        Dir.chdir(directory) { example.run }
      end
    end

    before do
      script = <<~RUBY
        #!#{RbConfig.ruby}
        require 'json'
        File.open('calls.jsonl', 'a') { |file| file.puts(JSON.generate(ARGV)) }
        exit(Integer(ENV.fetch('FAKE_TEX_STATUS', '0')))
      RUBY
      File.write('faketex', script)
      File.chmod(0o755, 'faketex')
      File.write('file.tex.erb', 'answer: {:= 6 * 7 :}')
    end

    def invoke_tex(*arguments, status: '0')
      run_erbtex(
        *arguments,
        env: { 'PATH' => "#{Dir.pwd}:#{ENV.fetch('PATH')}", 'FAKE_TEX_STATUS' => status },
      )
    end

    it 'preserves spaces, empty arguments, shell characters, and filenames across both passes' do
      filename = 'my  file; echo INJECTED.tex.erb'
      File.rename('file.tex.erb', filename)
      arguments = ['-jobname=a  b', '', 'literal $HOME & `echo bad`', filename]
      stdout, stderr, status = invoke_tex('--invoke=faketex', *arguments)

      expect(status.exitstatus).to eq(0), stderr
      expect(stdout).to eq('')
      expected = [*arguments[0...-1], 'my  file; echo INJECTED.tex']
      expect(File.readlines('calls.jsonl').map { |line| JSON.parse(line) }).to eq([expected, expected])
    end

    it 'propagates a failed TeX exit status and skips the second pass' do
      _, stderr, status = invoke_tex('--invoke=faketex', 'file.tex.erb', status: '7')

      expect(status.exitstatus).to eq(7), stderr
      expect(File.readlines('calls.jsonl').size).to eq(1)
    end

    it 'preprocesses without invoking TeX when preprocess-only is supplied' do
      _, stderr, status = invoke_tex('--preprocess-only', '--invoke=faketex', 'file.tex.erb')

      expect(status.exitstatus).to eq(0), stderr
      expect(File.read('file.tex')).to eq('answer: 42')
      expect(File.exist?('calls.jsonl')).to be(false)
    end

    it 'writes an etx file for tex input in preprocess-only mode' do
      File.rename('file.tex.erb', 'file.tex')
      _, stderr, status = invoke_tex('--preprocess-only', '--invoke=faketex', 'file.tex')

      expect(status.exitstatus).to eq(0), stderr
      expect(File.read('file.etx')).to eq('answer: 42')
      expect(File.exist?('calls.jsonl')).to be(false)
    end

    it 'fails without invoking TeX when preprocess-only has no input file' do
      _, stderr, status = invoke_tex('--preprocess-only', '--invoke=faketex')

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include('--preprocess-only requires an input file')
      expect(File.exist?('calls.jsonl')).to be(false)
    end

    it 'reports template failures in preprocess-only mode without invoking TeX' do
      File.write('file.tex.erb', '{: ) :}')
      _, stderr, status = invoke_tex('--preprocess-only', '--invoke=faketex', 'file.tex.erb')

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include('Erubis pre-processing failed:', 'file.tex.erb:1')
      expect(File.exist?('calls.jsonl')).to be(false)
      expect(File.exist?('file.tex')).to be(false)
    end

    it 'invokes an executable by its complete path with spaces and hyphens' do
      File.rename('faketex', 'fake tex-engine')
      executable = File.join(Dir.pwd, 'fake tex-engine')
      _, stderr, status = invoke_tex("--invoke=#{executable}", 'file.tex.erb')

      expect(status.exitstatus).to eq(0), stderr
      expect(File.readlines('calls.jsonl').map { |line| JSON.parse(line) }).to eq([['file.tex'], ['file.tex']])
    end

    it 'runs latexmk only once' do
      File.rename('faketex', 'latexmk')
      _, stderr, status = invoke_tex('--invoke=latexmk', 'file.tex.erb')

      expect(status.exitstatus).to eq(0), stderr
      expect(File.readlines('calls.jsonl').size).to eq(1)
    end

    it 'passes TeX commands without requiring an input file' do
      commands = ['\\relax', 'a  b', '\\end']
      _, stderr, status = invoke_tex('--invoke=faketex', *commands)

      expect(status.exitstatus).to eq(0), stderr
      expect(File.readlines('calls.jsonl').map { |line| JSON.parse(line) }).to eq([commands, commands])
    end
  end

  def run_erbtex(*arguments, env: {})
    root = File.expand_path('../..', __dir__)
    Open3.capture3(
      env,
      RbConfig.ruby,
      "-I#{File.join(root, 'lib')}",
      File.join(root, 'bin', 'erbtex'),
      *arguments,
    )
  end

  it 'prints help and exits successfully without processing a file' do
    stdout, stderr, status = run_erbtex('--help')

    expect(status.exitstatus).to eq(0), stderr
    expect(stdout).to include('Usage: erbtex', '--preprocess-only', 'without invoking TeX')
    expect(stderr).to eq('')
  end

  it 'prints version information and exits successfully without processing a file' do
    stdout, stderr, status = run_erbtex('--version')

    expect(status.exitstatus).to eq(0), stderr
    expect(stdout).to include("erbtex version: #{ErbTeX::VERSION}", 'Ruby version:', 'erubis version:')
    expect(stderr).to eq('')
  end
end
