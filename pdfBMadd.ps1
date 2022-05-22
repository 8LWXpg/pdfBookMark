param (
    [Parameter(ValueFromPipeline = $true)]
    [System.IO.FileInfo]$pdf,
    [string]$str,
    [int]$start = 1
)

if (-not $pdf) {
    $pdf = Read-Host 'pdf file path'
}
if (-not $str) {
    $str = Read-Host 'string to find'
}

# get "page","$str" from pdf strings
$get = gswin64c -sDEVICE=txtwrite -o- $pdf | Select-String $str, 'page'
if (!$?) {
    return
}

# loop through ench line and record continuous numbers in pages
$out = @()
$count = $start - 1
switch -regex ($get) {
    'page (\d+)' { $page = $Matches[1] }
    "$str +(\d+)" {
        if ($Matches[1] -eq $count + 1) {
            $out += $page
            $count = $Matches[1].ToInt32($null)
        }
    }
    Default {}
}

# add bookmarks
[System.IO.FileInfo]$temp = "$($pdf.DirectoryName)\$($pdf.BaseName)_BMadd$($pdf.Extension)"
if ($temp.Exists) {
    Remove-Item $temp
}
pdftk $pdf dump_data_utf8 output - | ForEach-Object {
    if ($_ -match 'NumberOfPages') {
        for ($i = 0; $i -lt $out.Count; $i++) {
            'BookmarkBegin'
            "BookmarkTitle: $str $($i+$start)"
            "BookmarkLevel: 1"
            "BookmarkPageNumber: $($out[$i])"
        }
    }
} | pdftk $pdf update_info_utf8 - output $temp
