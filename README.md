ErbTeX: Ruby pre-processing for TeX and LaTeX Documents
==========

# Description
erbtex is a ruby gem that pre-processes TeX and LaTeX source files
with ruby's erubis and then passes the resulting file along to a real
TeX program.

# Installation
Install it with:
    gem install erbtex

# Usage
After the gem is installed, erbtex is placed in your PATH in front of
the real TeX and LaTeX programs.  It is linked to the names pdflatex,
tex, pdftex, and so forth, so that it can be invoked with those names
on the input file.  It will read the source and execute any ruby code
between the markers `.{` and `}.`.  It will then find the real program
further along your path and run it on the pre-processed output.

# Example
For example, the following LaTeX file will produce a table of square
roots when run through erbtex:

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
    .{0.upto(100).each do |x| }.
    .{= "\\mathversion{bold}$%0.4f$" % x }.&
    .{= "$%0.8f$" % Math.sqrt(x) }.\\
    .{end}.
    \end{longtable}
    \end{document}

With the above in file `roots.tex`, running =$ pdflatex roots.tex= at
the command line will generate a `PDF` file with a nicely typeset
table of square roots.
