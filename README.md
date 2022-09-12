# pdfBookMarkAdd

find specific string in pdf then add it into bookmark

## Requirements

- [ghostscript](https://www.ghostscript.com/)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

both installed and added to the PATH

## Usage

### **find string in sepecific pages**

> `PS> all.ps1 <pdf> [<string>='Chapter'] [<pages to omit>]`

#### *for pages, use (1..10+15) to express page 1 to 10 plus page 15*

### **find string in table of contents**

> `PS> table.ps1 <pdf> <page range> <offset> [<string>='Chapter'] [-text <text file>]`

#### *Use 8,10 to specify page range 8-10*

#### *Pdf text output may be incorrect sometimes. In that case, please use `gs -sDEVICE=txtwrite` to output text then modify manually, and use -text switch instead of page range*

## Example

> `PS> all.ps1 <pdf>`

### before

![before](https://i.imgur.com/ETIQzxk.png)

### after

![after](https://i.imgur.com/OAsVc26.png)
