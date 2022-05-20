param (
    [Parameter(ValueFromPipeline = $true)]
    [System.IO.FileInfo]$pdf,
    [string]$str
)

if (-not $pdf) {
    $pdf = Read-Host 'pdf file path'
}
if (-not $str) {
    $str = Read-Host 'string to find'
}

$get = gswin64c -sDEVICE=txtwrite -o- $pdf | Select-String $str, 'page'
if (!$?) {
    return
}

$out = @()
$count = 0
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

$temp = "$($pdf.DirectoryName)\$($pdf.BaseName)_BMadd$($pdf.Extension)"
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
