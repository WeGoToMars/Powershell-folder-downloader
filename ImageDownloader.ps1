Import-Module BitsTransfer

$root = Read-Host 'Paste a link to a folder you need to download from'
$folder = ($root -split '/')[-2]
Write-Output $folder
New-Item -Path "$HOME\Downloads\" -Name $folder -ItemType "directory"
$links = (Invoke-WebRequest -Uri $root).Links.href
$files = $links[5..($links.Count-1)]

for ($i = 0; $i -le $files.Count-1; $i++) {
    $file = -join($root, $files[$i])
    $path = -join("$HOME\Downloads\",$folder,'\',$files[$i])
    $download = Start-BitsTransfer -Source $file -Destination $path -Asynchronous
    while ($download.JobState -ne "Transferred") {
        $downloaded = [Math]::floor([decimal]$download.BytesTransferred/1024/1024)
        $total = [Math]::floor([decimal]$download.BytesTotal/1024/1024)
        [int] $dlProgress = ($downloaded / $total) * 100;
        Write-Progress -Activity "Downloading file $($i+1) out of $($files.Count) : $path" -Status "(Transfered $downloaded MB out of $total MB), $dlProgress% Complete:" -PercentComplete $dlProgress; 
    }
    Complete-BitsTransfer $download.JobId;
}