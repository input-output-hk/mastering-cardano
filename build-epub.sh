#!/usr/bin/env bash
set -euo pipefail

# ── book specific ────────────────────────────────────────────────────
FILENAME="mastering-cardano"
VERSION="v1.0.0"

# ── locate toolchain (absolute) ──────────────────────────────────────
TNGROOT="$(realpath tools/docbook-xslTNG-2.5.0)"
SAXON_CP="$TNGROOT/libs/lib/Saxon-HE-12.5.jar:$TNGROOT/libs/docbook-xslTNG-2.5.0.jar"
EPUB_XSL="$TNGROOT/xslt/epub.xsl"
PYG_CSS_SRC="$TNGROOT/resources/css/pygments.css"

# ── output layout ────────────────────────────────────────────────────
OUTDIR="dist"
ABS_OUTDIR="$(realpath -m "$OUTDIR")"   # -m: don’t fail if it doesn’t exist yet
mkdir -p "$ABS_OUTDIR"

SRC_XML="$ABS_OUTDIR/${FILENAME}-${VERSION}.xml"
CHUNK_URI="file:///$ABS_OUTDIR/"          # where TNG writes OPS/, META-INF/, …

EPUB_NAME="${FILENAME}-${VERSION}.epub"
EPUB_PATH="$ABS_OUTDIR/$EPUB_NAME"

echo "▸ cleaning $OUTDIR/"; rm -rf "$ABS_OUTDIR"/*

echo "▸ Asciidoctor  ➜  DocBook"
bundle exec asciidoctor -b docbook \
  -a imagesdir=images --failure-level WARN \
  -a version="${VERSION}" \
  main.adoc -o "$SRC_XML"

echo "▸ Staging images for XSLT processor"
cp -r images "$ABS_OUTDIR/"


echo "▸ DocBook      ➜  XHTML chunks (XSL TNG)"
(  cd "$ABS_OUTDIR"
   java -cp "$SAXON_CP" net.sf.saxon.Transform \
       -init:org.docbook.xsltng.extensions.Register \
       -ext:on \
       -xsl:"$EPUB_XSL" \
       -s:"${FILENAME}-${VERSION}.xml" \
       base.dir="./" \
       chunk-output-base-uri="./" \
       epub.filename="$EPUB_NAME" \
       verbatim-syntax-highlighter=pygments \
       pygments.style=github \
       pygmentize.command=/usr/bin/pygmentize \
       verbatim-syntax-highlight-languages="shell sh console haskell json typescript javascript" \
       cover.image.filename="images/cover.png" \
       epub.stylesheet=css/pygments.css )

# ─────────────────────────────────────────────────────────────────────
# add resources the stylesheet doesn’t copy automatically
mkdir -p "$ABS_OUTDIR/OPS/css"
cp "$PYG_CSS_SRC" "$ABS_OUTDIR/OPS/css/"
# Images are already in dist/images, but we need them inside OPS for the EPUB structure
cp -r "$ABS_OUTDIR/images" "$ABS_OUTDIR/OPS/"
cp cover.xhtml "$ABS_OUTDIR/OPS/"

echo "▸ Patching package.opf to mark cover image"
sed -i 's|\(<manifest>\)|\1\n    <item id="cover" href="images/cover.png" media-type="image/png" properties="cover-image"/>\n    <item id="cover-page" href="cover.xhtml" media-type="application/xhtml+xml"/>|' "$ABS_OUTDIR/OPS/package.opf"
sed -i 's|\(<spine>\)|\1\n    <itemref idref="cover-page" linear="yes"/>|' "$ABS_OUTDIR/OPS/package.opf"

# The image paths should be correct now, but we keep this as a safeguard
echo "▸ Fixing image paths in XHTML files"
for file in $(find "$ABS_OUTDIR/OPS" -name "*.xhtml"); do
  sed -i 's|src="[^"]*images/|src="images/|g' "$file"
done


# ── create mimetype (just in case) ───────────────────────────────────
echo "application/epub+zip" > "$ABS_OUTDIR/mimetype"

echo "▸ Packaging EPUB"
(
  cd "$ABS_OUTDIR"
  # store mimetype first, uncompressed (-0)
  zip -X0 "$EPUB_NAME" mimetype >/dev/null
  # then the rest, compressed (-9)
  zip -r9 "$EPUB_NAME" META-INF OPS >/dev/null
)

# ── optional check ───────────────────────────────────────────────────
if command -v epubcheck >/dev/null; then
  epubcheck "$EPUB_PATH" || true
fi

echo "✅  Finished  →  $EPUB_PATH"
