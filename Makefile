FILENAME=mastering-cardano
VERSION=v1.0.0

all: epub pdf

epub:
	bundle exec asciidoctor-epub3 \
		-r asciidoctor-diagram \
		-a imagesdir=images \
		-a rouge-style=github \
		--failure-level WARN \
		main.adoc \
		-o dist/$(FILENAME)-$(VERSION).epub

pdf:
	bundle exec asciidoctor-pdf \
		-r asciidoctor-diagram \
		-r ./theme/custom-highlight.rb \
		-a rouge-style=custom-highlight \
		-a imagesdir=images \
		-a pdf-themesdir=theme \
		-a pdf-fontsdir="theme;GEM_FONTS_DIR" \
		-a pdf-theme=custom \
		--failure-level WARN \
		main.adoc \
		-o dist/$(FILENAME)-$(VERSION).pdf

clean:
	git clean -xdf
