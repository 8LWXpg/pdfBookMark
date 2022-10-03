param (
	[Parameter(ValueFromPipeline = $true)]
	[System.IO.FileInfo]$pdf,
	[string]$str = 'Chapter',
	[int[]]$omit = $null
)

if (!$pdf.Exists -or $pdf.Extension -ne '.pdf') {
	Write-Error 'pdf not found' -Category OpenError
	return
}
if (!$str) {
	Write-Error 'no string to match specified' -Category InvalidArgument
	return
}


# get "page","$str" from the text in pdf
$get = gswin64c -sDEVICE=txtwrite -q -o- $pdf | Select-String $str, 'page' || return

# loop through each line and record continuous numbers in pages
$out = @()
$count = 0
$cur_page = '1'
switch -regex ($get) {
	'page (\d+)' {
		$cur_page = $Matches[1]
	}
	"$str *(\d+)" {
		if ($Matches[1] -eq $count + 1 -and $cur_page -notin $omit) {
			$out += $cur_page
			$count = $Matches[1].ToInt32($null)
		}
	}
	Default {}
}


# add bookmarks
[System.IO.FileInfo]$temp = "$($pdf.DirectoryName)\$($pdf.BaseName)_BMadd.pdf"
if ($temp.Exists) {
	Remove-Item $temp
}
pdftk $pdf dump_data_utf8 output - | ForEach-Object {
	if ($_ -match 'NumberOfPages') {
		for ($i = 0; $i -lt $out.Count; $i++) {
			'BookmarkBegin'
			"BookmarkTitle: $str $($i+1)"
			"BookmarkLevel: 1"
			"BookmarkPageNumber: $($out[$i])"
		}
	}
} | pdftk $pdf update_info_utf8 - output $temp
