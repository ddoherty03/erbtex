ErbTeX: Ruby pre-processing for TeX and LaTeX Documents
==========

# Description

erbtex is a ruby gem that provides a command line program the
pre-processes TeX and LaTeX source files with ruby's erubis and then
passes the resulting file along to a real TeX program.

# Installation

  Install it with:
    gem install erbtex

# Usage

After the gem is installed, erbtex is placed in your PATH in front of
the real TeX and LaTeX programs, along with links to erbtex having the
names pdftex, pdflatex, luatex, and several other TeX processing
programs.  Thus, invoking, for example, `pdflatex` runs `erbtex`
instead of the real `pdflatex` program.

It will then read the input file and execute any ruby code between the special
markers markers `{:` and `:}` and then find the real program further along
your path and run it on the pre-processed output.  The result is that you can
use the ruby programming language to greatly increase the computational
capabilities of a normal TeX or LaTeX file.

erbtex simply uses the `erubis` program to pre-process the input, except that
it uses the `{: :}` delimiters instead of the erubis default of `<% %>`.  The
brace-colon form of delimiters is less disruptive of syntax highlighting than
the default delimiters, which get confused with TeX and LaTeX comments.

If the opening delimiter has an `=` appended to it, the contained expression
is converted into a string and inserted in-place into the TeX manuscript at
that point.  Without the `=` the code is simply executed.  Loops started in
one ruby fragment can be continued or terminated in a later fragment, and
variables defined in one fragment in one fragment are visible in later
fragments according to Ruby's usual scoping rules.

# Example

For example, the following LaTeX file will produce a table of square
roots when run through erbtex.  It uses a ruby iterator to supply the
rows of the table, a feat that would tedious at best with bare TeX or
LaTeX.

    \documentclass{article}
    \usepackage[mathbf]{euler}
    \usepackage{longtable}

    \begin{document}
        \begin{longtable}[c]{r|r}
    \hline\hline
    \multicolumn{1}{c|}{\mathversion{bold}$x$}&
    \multicolumn{1}{c}{\mathversion{bold}\rule{0pt}{12pt}$\sqrt{x}$}\\
    \hline\hline
    \endhead
    \hline\hline
    \endfoot
    % The following line starts a ruby enumerator loop but does not
    % produce any output, since the delimiters are {: :}.
    {: 0.upto(100).each do |x| :}
      % But the following two lines produce out put since the opening
      % delimiter is '{:='.  Both call the sprintf method in ruby via the
      % percent operator, and the second line calls ruby's Math module to
      % compute the square root.
      {:= "\\mathversion{bold}$%0.4f$" % x :}&
      {:= "$%0.8f$" % Math.sqrt(x) :}\\
    {: end :}
    \end{longtable}
    \end{document}

With the above in file `roots.tex`, running `$ pdflatex roots.tex` at
the command line will generate a `PDF` file with a nicely typeset
table of square roots.

As a by-product, the pre-processed file `roots.etx` is left in the
same directory, so you can see what the effect of the erbtex fragments
were.  This is often very handy when you are trying to debug the
document; otherwise, it can be deleted.  Here, for example is a
portion of the `roots.etx` file generated by the foregoing:

    \begin{document}
      \begin{longtable}[c]{r|r}
      \hline\hline
      \multicolumn{1}{c|}{\mathversion{bold}$x$}&
      \multicolumn{1}{c}{\mathversion{bold}\rule{0pt}{12pt}$\sqrt{x}$}\\
      \hline\hline
      \endhead
      \hline\hline
      \endfoot
      \mathversion{bold}$0.0000$&
      $0.00000000$\\
      \mathversion{bold}$1.0000$&
      $1.00000000$\\
      \mathversion{bold}$2.0000$&
      $1.41421356$\\
      \mathversion{bold}$3.0000$&
      $1.73205081$\\
      \mathversion{bold}$4.0000$&
      $2.00000000$\\
      \mathversion{bold}$5.0000$&
      $2.23606798$\\
      \mathversion{bold}$6.0000$&
      $2.44948974$\\
      \mathversion{bold}$7.0000$&
      $2.64575131$\\
      \mathversion{bold}$8.0000$&
      $2.82842712$\\
      \mathversion{bold}$9.0000$&
      $3.00000000$\\
      \mathversion{bold}$10.0000$&
      $3.16227766$\\
      \mathversion{bold}$11.0000$&
      $3.31662479$\\
      \mathversion{bold}$12.0000$&
      $3.46410162$\\
      \mathversion{bold}$13.0000$&
      $3.60555128$\\
      \mathversion{bold}$14.0000$&

And many more lines like it.

The examples directory installed with the erbtex gem has a few more
examples.
