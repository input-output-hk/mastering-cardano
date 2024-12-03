# Instructions for code styling

In order to use the code styling features the following packages need to be installed: 
* asciidoctor-pdf
* [rouge](https://docs.asciidoctor.org/asciidoctor/latest/syntax-highlighting/rouge/#install-rouge)

## Styling your code

You need to add the following line to the start of your document:
```shell
:source-highlighter: rouge
:rouge-style: style
```

You can pick the style of your code from the following [list of themes](https://github.com/rouge-ruby/rouge/tree/master/lib/rouge/themes).
To define a custom theme read the official documentation for [custom themes](https://docs.asciidoctor.org/pdf-converter/latest/theme/source-highlighting-theme/#define-a-custom-highlighting-theme).

## Convert to PDF 

To convert a `adoc` file into a `pdf` file taking your code styling into account use:
```
asciidoctor-pdf -a source-highlighter=rouge yourfile.adoc
```

## Code styling examples  

You can find in the `examples/` folder code styling examples for the `code_template.adoc` file that is added to the `code_styling` folder. 
