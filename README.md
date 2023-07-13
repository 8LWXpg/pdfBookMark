# pdfBookMark

extract table of contents from pdf into bookmarks

## Requirements

- [ghostscript](https://www.ghostscript.com/)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
- pdftotext (from poppler, may included in Tex distributions)
  - [Windows](https://github.com/oschwartz10612/poppler-windows/releases)

both installed and added to the PATH

## Usage

### find string in specific pages

```
PS> all.ps1 <pdf> [<string> = 'Chapter'] [<pages to omit>]
```

#### *for pages, use (1..10+15) to express page 1 to 10 plus page 15*

### extract table of contents

```
PS> table.ps1 <pdf> <page range> [<page count of page 1>] [<str>] [<separate char>]
```

#### *Use 8,10 to specify page range 8-10*

### modify the text manually if the result is not accurate

If the OCR-generated text from the PDF file is inaccurate, you can use this command to extract the text with the original layout:

```
PS> pdftotext -f <first page> -l <last page> -layout -nopgbrk -raw <pdf> <output>
```

You can then edit the text file manually to correct any errors, and use

```
PS> table.ps1 <pdf> [<page count of page 1>] [<str>] [<separate char>] -text <text file>
```

## Example

### all.ps1

![all](https://i.imgur.com/h8xHWwV.png)

### table.ps1

![table](https://i.imgur.com/5sPGb7t.png)
