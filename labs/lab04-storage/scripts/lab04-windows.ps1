# Lab 4, Windows part - partition, format, assign a letter on the extra 1 GB disk
# Run inside lab02-windows in an ADMIN PowerShell:
#   powershell -ExecutionPolicy Bypass -File \\VBoxSvr\lab04\scripts\lab04-windows.ps1
# Writes evidence\windows-disk.txt next to this script (shared folder = repo folder on the host).
$ErrorActionPreference = 'Stop'
$out = Join-Path $PSScriptRoot '..\evidence\windows-disk.txt'

function Invoke-Logged([string]$cmd) {
    "PS $env:COMPUTERNAME> $cmd"
    (Invoke-Expression $cmd | Out-String -Width 200).TrimEnd()
    ''
}

$raw = Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Select-Object -First 1
if (-not $raw) { throw 'No RAW (uninitialised) disk found - is the 1 GB lab04 disk attached?' }
$n = $raw.Number
$letter = 'R'

$log = @(
    "# Lab 4 - Windows side - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') on $env:COMPUTERNAME"
    ''
    '## Before'
    Invoke-Logged 'Get-Disk | Format-Table Number, FriendlyName, PartitionStyle, OperationalStatus, @{n="Size(GB)";e={[math]::Round($_.Size/1GB,1)}} -AutoSize'
    Invoke-Logged 'Get-Volume | Sort-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, HealthStatus, @{n="Size(GB)";e={[math]::Round($_.Size/1GB,1)}} -AutoSize'
    '## Partition, format, assign a letter'
    Invoke-Logged "Initialize-Disk -Number $n -PartitionStyle GPT -PassThru | Format-Table Number, PartitionStyle -AutoSize"
    Invoke-Logged "New-Partition -DiskNumber $n -UseMaximumSize -DriveLetter $letter | Format-Table DiskNumber, PartitionNumber, DriveLetter, Type, @{n='Size(MB)';e={[math]::Round(`$_.Size/1MB)}} -AutoSize"
    Invoke-Logged "Format-Volume -DriveLetter $letter -FileSystem NTFS -NewFileSystemLabel LAB04 -Confirm:`$false | Format-Table DriveLetter, FileSystemLabel, FileSystem, HealthStatus -AutoSize"
    '## After'
    Invoke-Logged 'Get-Disk | Format-Table Number, FriendlyName, PartitionStyle, OperationalStatus, @{n="Size(GB)";e={[math]::Round($_.Size/1GB,1)}} -AutoSize'
    Invoke-Logged "Get-Partition -DiskNumber $n | Format-Table PartitionNumber, DriveLetter, Type, GptType, @{n='Size(MB)';e={[math]::Round(`$_.Size/1MB)}} -AutoSize"
    Invoke-Logged 'Get-Volume | Sort-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, HealthStatus, @{n="Size(GB)";e={[math]::Round($_.Size/1GB,1)}} -AutoSize'
    Invoke-Logged 'Get-ComputerInfo -Property BiosFirmwareType | Format-List    # UEFI firmware -> boot disk must be GPT'
)
$log | Set-Content -Path $out -Encoding utf8
Get-Content $out
"`nSaved to $out"
