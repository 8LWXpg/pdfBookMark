# pdfBookMarkAdd

find specific string in pdf then add it into bookmark

## Requirements

- [ghostscript](https://www.ghostscript.com/)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

both installed and added to the PATH

## Usage

`PS> pdfBMadd.ps1 <pdf> <string> [<start count>]`

### before

![before](https://i.imgur.com/ETIQzxk.png)

### after

`PS> pdfBMadd.ps1 <pdf> Chapter`

![after](https://i.imgur.com/OAsVc26.png)
