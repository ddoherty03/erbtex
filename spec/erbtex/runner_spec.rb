# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'rbconfig'

describe ErbTeX do
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
