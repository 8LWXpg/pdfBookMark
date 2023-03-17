param (
	[Parameter(ValueFromPipeline, Mandatory)]
	[string]$pdf,
	[int[]]$page,
	[int]$offset = 1,
	[string]$str = 'Chapter',
	[string]$char = '.',
	[string]$text
)

# get table of content and match
if ($text) {
	[System.IO.FileInfo]$text = (Resolve-Path $text).Path
	if (!$text.Exists) {
		Write-Error "File not found: $text"
		Exit
	}
}
[System.IO.FileInfo]$pdf = (Resolve-Path $pdf).Path
if (!$pdf.Exists || $pdf.Extension -ne '.pdf') {
	Write-Error "File not found: $pdf"
	Exit
}
$get = $text ? (Get-Content $text.FullName -Raw)
:(pdftotext -f $page[0] -l $page[-1] -layout -nopgbrk -raw $pdf - | Out-String)

$level1 = @((Select-String "$str *(\d+)\D+?(?:(\S+)\s+)+?(\d+)" -InputObject $get -AllMatches).Matches | ForEach-Object {
		# convert to lower case and capitalize first letter
		$temp = ("$str $($_.Groups[1].Value) $($_.Groups[2].Captures)").ToLower().ToCharArray()
		$temp[0] = [char]::ToUpper($temp[0])
		[PSCustomObject]@{
			Str  = [string]::new($temp)
			Page = $_.Groups[3].Value.ToInt32($null)
		}
	})
$level1 = $level1 | Sort-Object Page
$level2 = @()
for ($i = 1; $i -le $level1.Count; $i++) {
	$temp_table = @((Select-String "(?<!\d)($i\.\d+)\D+?(?:(\S+)\s+)+?(\d+)" -InputObject $get -AllMatches).Matches | ForEach-Object {
			# convert to string then insert space before upper case letter if it doesn't has one
			$temp = "$($_.Groups[2].Captures)"
			$temp = $temp -creplace '([a-z])([A-Z])', '$1 $2'
			[PSCustomObject]@{
				Str  = "$($_.Groups[1].Value) $temp"
				Page = $_.Groups[3].Value.ToInt32($null)
			}
		})
	$level2 += , ($temp_table | Sort-Object Page)
}

# add bookmarks
[System.IO.FileInfo]$tmpfile = "$($pdf.DirectoryName)\$($pdf.BaseName)_BMadd.pdf"
if ($tmpfile.Exists) {
	Remove-Item $tmpfile
}
$offset -= 1
pdftk $pdf dump_data_utf8 output - | ForEach-Object {
	$_
	if ($_ -match 'NumberOfPages') {
		for ($i = 0; $i -lt $level1.Count; $i++) {
			'BookmarkBegin'
			"BookmarkTitle: $($level1[$i].Str)"
			'BookmarkLevel: 1'
			"BookmarkPageNumber: $($level1[$i].Page+$offset)"
			for ($j = 0; $j -lt $level2[$i].Count; $j++) {
				'BookmarkBegin'
				"BookmarkTitle: $($level2[$i][$j].Str)"
				'BookmarkLevel: 2'
				"BookmarkPageNumber: $($level2[$i][$j].Page+$offset)"
			}
		}
	}
} | pdftk $pdf update_info_utf8 - output $tmpfile