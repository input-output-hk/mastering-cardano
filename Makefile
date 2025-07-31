FILENAME=mastering-cardano
VERSION=v1.0.0

all: epub pdf

epub:
	bundle exec asciidoctor-epub3 \
		-a imagesdir=images \
		-a rouge-style=github \
		--failure-level WARN \
		main.adoc \
		-o dist/$(FILENAME)-$(VERSION).epub

epub-docbook: dist/$(FILENAME)-$(VERSION).xml dist/mimetype
	rm -rf dist/OEBPS dist/META-INF
	cd dist && \
	xsltproc --stringparam cover.image.filename "$(COVER_IMAGE)" \
	/usr/share/xml/docbook/xsl-stylesheets-1.79.2/epub/docbook.xsl \
	$(FILENAME)-$(VERSION).xml
	sed -i 's|\(<item.*href="images/cover.png".*\)/>|\1 properties="cover-image"/>|' dist/OEBPS/content.opf
	cp -r images dist/OEBPS/
	cd dist && \
	zip -r $(FILENAME)-$(VERSION).epub mimetype OEBPS META-INF
	rm -rf dist/OEBPS dist/META-INF dist/mimetype dist/$(FILENAME)-$(VERSION).xml

dist/mimetype:
	@mkdir -p dist
	@echo "application/epub+zip" > dist/mimetype

dist/$(FILENAME)-$(VERSION).xml: main.adoc
	bundle exec asciidoctor \
		-b docbook \
		-a imagesdir=images \
		-a rouge-style=github \
		--failure-level WARN \
		main.adoc \
		-o dist/$(FILENAME)-$(VERSION).xml

pdf:
	bundle exec asciidoctor-pdf \
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
