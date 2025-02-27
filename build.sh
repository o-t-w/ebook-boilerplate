# Defaults
TITLE='ebook'
EPUB='true'
PDF='false'
HTML='false'
ZIP='false'
ALL='false'
COVER='false'

# Merge options into defaults
while getopts t:epmhca option
do
case "${option}"
in
t) TITLE=${OPTARG};;
e) EPUB='true' ALL='false';;
p) PDF='true' ALL='false';;
h) HTML='true' ALL='false';;
h) ZIP='true';;
a) ALL='true';;
c) COVER='true';;
esac
done

# EPUB
if [ $ALL == 'true' ] || [ $EPUB == 'true' ] ; then
	pandoc assets/metadata.yml chapters/*.md -o $TITLE.epub -t epub+smart
fi


# PDF
if [ $ALL == 'true' ] || [ $PDF == 'true' ] ; then
	## Temp PDF
	pandoc assets/title.md assets/toc.md chapters/*.md assets/scripts.md -o $TITLE-temp.pdf -t html5+smart -V papersize:"letter" -c assets/pandoc.css --metadata pagetitle="$TITLE"

	## Merge Cover
	if [ $COVER == 'true' ] ; then
		/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -o $TITLE.pdf assets/cover.pdf $TITLE-temp.pdf
	else
		/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -o $TITLE.pdf $TITLE-temp.pdf
	fi

	## Remove Temp
	rm $TITLE-temp.pdf
fi

# HTML
if [ $ALL == 'true' ] || [ $HTML == 'true' ] ; then
	pandoc -H assets/pandoc-before.css -H assets/pandoc.css -H assets/pdf-overrides.css -H assets/pandoc-after.css assets/title.md assets/toc.md chapters/*.md assets/scripts.md -o $TITLE.html -t html5+smart --metadata pagetitle="$TITLE"
fi

# Zip
if [ $ALL == 'true' ] || [ $ZIP == 'true' ] ; then
	if [ $ALL == 'true' ] ; then
		zip $TITLE.zip $TITLE.epub $TITLE.pdf $TITLE.html
	else
		echo "WARNING: ZIP file can only be created if all other formats are also supported"
	fi
fi