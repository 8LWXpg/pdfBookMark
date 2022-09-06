# pdfBookMarkAdd

find specific string in pdf then add it into bookmark

## Requirements

- [ghostscript](https://www.ghostscript.com/)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

both installed and added to the PATH

## Usage

### **find string in sepecific pages**

> `PS> pdfBMadd.ps1 <pdf> <string> [<pages to omit>] [<start count>]`

### **find string in table of contents**

> `PS> pdfBMadd.ps1 <pdf> <string> <page range> [<start count>] -content`

#### *for page range, use (1..10+15) to express page 1 to 10 plus page 15*

## Example

> `PS> pdfBMadd.ps1 <pdf> Chapter`

### before

![before](https://i.imgur.com/ETIQzxk.png)

### after

![after](https://i.imgur.com/OAsVc26.png)
