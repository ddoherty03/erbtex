require 'tempfile'
require 'pathname'
require 'English'

# Name space module for erbtex program.
module ErbTeX
  def self.run(cmd)
    report_env
    tex_dir = input_dir(cmd.input_file)
    tex_file = erb_to_tex(cmd.input_file, tex_dir) if cmd.input_file
    run_tex(cmd.tex_command(tex_file), tex_dir)
  end

  def self.report_env
    warn "Ruby VERSION: #{RUBY_VERSION}"
    warn "PATH: #{ENV['PATH']}"
  end

  # Run the TeX program, adding add_dir to the front of TEXINPUTS, unless it is
  # already in TEXINPUTS.
  def self.run_tex(cmd, add_dir = nil)
    new_env = {}
    if add_dir
      add_dir = File.absolute_path(File.expand_path(add_dir))
      unless ENV['TEXINPUTS'].split(File::PATH_SEPARATOR)
               .reject { |p| p.strip.empty? }
               .any? { |p| add_dir == File.absolute_path(File.expand_path(p)) }
        new_env['TEXINPUTS'] = "#{add_dir}:#{ENV['TEXINPUTS']}"
      end
    end
    unless system(cmd)
      warn "Call to '#{cmd}' failed."
      exit $CHILD_STATUS
    end
    $CHILD_STATUS
  end

  def self.input_dir(in_file)
    return nil unless in_file

    in_file_absolute = File.absolute_path(File.expand_path(in_file))
    in_file_absolute[%r{\A(.*/)([^/.]+)(\.[\w.]+)\z}, 1]
  end

  # Pre-process the input file with erubis, adding the add_dir to the front of
  # the ruby load path if its not already in the load path.  Return the name of
  # the processed file.
  def self.erb_to_tex(in_file, add_dir = nil)
    if File.exist?(add_dir)
      add_dir = File.absolute_path(File.expand_path(add_dir))
      unless $LOAD_PATH
               .any? { |p| add_dir == File.absolute_path(File.expand_path(p)) }
        $LOAD_PATH.unshift(add_dir)
      end
    end

    in_contents = nil
    File.open(in_file) do |f|
      in_contents = f.read
    end
    # TODO: recurse through any \input or \include commands

    pat = ENV['ERBTEX_PATTERN'] || '{: :}'

    out_file = out_file_name(in_file)
    File.open(out_file, 'w') do |f|
      er = ::Erubis::Eruby.new(in_contents, pattern: pat)
      f.write(er.result)
    end
    out_file
  rescue SystemCallError => e
    warn "Error: #{e}"
    exit 1
  rescue ScriptError => e
    warn "Erubis pre-processing failed: #{e}"
    exit 1
  end

  def self.out_file_name(in_file)
    in_file_absolute = File.absolute_path(File.expand_path(in_file))
    in_dir = File.dirname(in_file_absolute)
    in_base = File.basename(in_file_absolute)
    in_ext = File.extname(in_file_absolute)

    out_ext = if in_ext.empty?
                if File.exist?("#{in_file}.tex.erb")
                  '.tex'
                elsif File.exist?("#{in_file}.tex")
                  '.etx'
                elsif File.exist?("#{in_file}.erb")
                  '.tex'
                else
                  '.tex'
                end
              else
                case in_ext
                when '.tex.erb'
                  '.tex'
                when '.tex'
                  '.etx'
                when '.erb'
                  '.tex'
                else
                  '.tex'
                end
              end

    # Find a writable directory, prefering the one the input file came
    # from, or the current directory, and a temp file as a last resort.
    if File.writable?(in_dir)
      File.join(in_dir, "#{in_base}#{out_ext}")
    elsif File.writable?('.')
      File.join('.', "#{in_base}#{out_ext}")
    else
      Tempfile.new([in_base, out_ext]).path
    end
  end
end
