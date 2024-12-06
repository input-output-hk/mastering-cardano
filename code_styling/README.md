# Instructions for code styling and text colorization

In order to use the code styling features the following packages need to be installed: 
* asciidoctor-pdf
* [rouge](https://docs.asciidoctor.org/asciidoctor/latest/syntax-highlighting/rouge/#install-rouge)

## Styling your code 

You need to add the following line to the start of your document:
```
:source-highlighter: rouge
:rouge-style: style
```

You can pick the style of your code from the following [list of themes](https://github.com/rouge-ruby/rouge/tree/master/lib/rouge/themes).
To define a custom theme read the official documentation for [custom themes](https://docs.asciidoctor.org/pdf-converter/latest/theme/source-highlighting-theme/#define-a-custom-highlighting-theme).

## Colorizing text 

`asciidoctor-pdf` does not support built-in colors. You must define them in your own theme. The `custom-theme.yml` file in this folder is an example of a theme needed for `chapter-8-writing-smart-contracts.adoc`. It defines the blue and purple color fonts.  

You need to add the following line to the start of your document:
```
:pdf-theme: custom-theme.yml
```

Then you can use the colors defined in `custom-theme.yml` in your asciidoc file as follows:
``` 
Refering to [blue]#functionName# and [purple]#DataType#. 
```

You can read more about themes in the [Create a theme](https://docs.asciidoctor.org/pdf-converter/latest/theme/create-theme/) official documentation page. 

## Convert to PDF 

To convert a `adoc` file into a `pdf` file taking your code styling into account use:
```
asciidoctor-pdf code_template.adoc
```

In case of issues you can also specify the source code highlighter and the custom 
theme as options in the command: 
```
asciidoctor-pdf -a source-highlighter=rouge -a pdf-theme=custom-theme.yml code_template.adoc
```

## Code styling examples  

In the `examples/` folder you can find PDF examples for the `code_template.adoc` file for all possible styles that the rouge-ruby project has to offer. 
