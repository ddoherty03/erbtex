module ErbTeX
  # Given an arbitrary file name, parse it into its components in one go.  It
  # separates three parts of a filename: (1) the directory, if any, (2) the
  # base name (including such things as .configrc) which is considered a base
  # name rather than an extension, and (3) any extension, including a compound
  # extension such as .tex.erb
  def self.parse_file_name(path)
    fn_re = %r{\A(?<dir>([^\/]*\/)*)  (?<base>.?[^\/.]*)  (?<ext>\.[\w.]+)?}x
    md = fn_re.match(path)
    { dir: md[:dir], base: md[:base], ext: md[:ext] }
  end

  # Return the name of the input file based on the name given in the command
  # line. Try to add the right extension for the input file if none is given.
  def self.expand_input_file(input_file)
    return '' if input_file.blank?

    fn = ErbTeX.parse_file_name(input_file)
    input_dir = fn[:dir]
    input_base = fn[:base]
    input_ext = fn[:ext]
    if input_ext.nil?
      path = "#{input_dir}#{input_base}"
      if File.exist?("#{path}.tex.erb")
        "#{path}.tex.erb"
      elsif File.exist?("#{path}.tex")
        "#{path}.tex"
      elsif File.exist?("#{path}.erb")
        "#{path}.erb"
      else
        input_base
      end
    else
      input_file
    end
  end

  # Map the extension of the erbtex input file to the extension of the erubis
  # output file in the following order of preference:
  #
  # base.tex.erb -> base.tex
  # base.tex -> base.etx
  # base.erb -> base.tex
  # base.* -> base.tex
  def self.out_file_name(in_file)
    fn_parts = parse_file_name(in_file)
    in_base = fn_parts[:base]
    in_ext = fn_parts[:ext]

    out_ext =
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
    # Do not include the input directory, only output to current directory.
    "#{in_base}#{out_ext}"
  end
end
