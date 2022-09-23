param (
	[Parameter(ValueFromPipeline = $true)]
	[System.IO.FileInfo]$pdf,
	[int[]]$page,
	[int]$offset = 0,
	[string]$str = 'Chapter',
	[string]$char = '.',
	[System.IO.FileInfo]$text = $null
)

if (!$pdf.Exists -or $pdf.Extension -ne '.pdf') {
	Write-Error 'pdf not found'
	return
}
if (!$str) {
	Write-Error 'no string to match specified'
	return
}
if (!$page -and !$text.Exists) {
	Write-Error 'no content page specified'
	return
}

# get table of content and match
if ($text) {
	$get = Get-Content $text.FullName
} else {
	$get = gswin64c -sDEVICE=txtwrite -q "-dFirstPage=$($page[0])" "-dLastPage=$($page[-1])" -o- $pdf
}
$level1 = @((Select-String "$str *(\d+)\D+?(?:(\S+)\s+)+?(\d+)" -InputObject ($get -join "`n") -AllMatches).Matches | ForEach-Object {
		[PSCustomObject]@{
			Str  = "$str $($_.Groups[1].Value) $($_.Groups[2].Captures)"
			Page = $_.Groups[3].Value.ToInt32($null)
		}
	})
$level2 = @()
for ($i = 1; $i -le $level1.Count; $i++) {
	$level2 += , @((Select-String "(?<!\d)($i\.\d+)\D+?(?:(\S+)\s+)+?(\d+)" -InputObject ($get -join "`n") -AllMatches).Matches | ForEach-Object {
			[PSCustomObject]@{
				Str  = "$($_.Groups[1].Value) $($_.Groups[2].Captures)"
				Page = $_.Groups[3].Value.ToInt32($null)
			}
		})
}

# add bookmarks
[System.IO.FileInfo]$temp = "$($pdf.DirectoryName)\$($pdf.BaseName)_BMadd.pdf"
if ($temp.Exists) {
	Remove-Item $temp
}
pdftk $pdf dump_data_utf8 output - | ForEach-Object {
	$_
	if ($_ -match 'NumberOfPages') {
		for ($i = 0; $i -lt $level1.Count; $i++) {
			'BookmarkBegin'
			"BookmarkTitle: $($level1[$i].Str)"
			"BookmarkLevel: 1"
			"BookmarkPageNumber: $($level1[$i].Page+$offset)"
			for ($j = 0; $j -lt $level2[$i].Count; $j++) {
				'BookmarkBegin'
				"BookmarkTitle: $($level2[$i][$j].Str)"
				"BookmarkLevel: 2"
				"BookmarkPageNumber: $($level2[$i][$j].Page+$offset)"
			}
		}
	}
} | pdftk $pdf update_info_utf8 - output $temp