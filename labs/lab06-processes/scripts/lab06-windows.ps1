# Lab 6, Windows part. Run inside lab02-windows in an ADMIN PowerShell:
#   powershell -ExecutionPolicy Bypass -File \\VBoxSvr\lab06\scripts\lab06-windows.ps1
# 1) facts about services.exe (Windows service manager) for the comparison with Task Manager / Process Explorer
# 2) memory pressure until Windows reports low virtual memory
# 3) the matching event from the Windows event log (Resource-Exhaustion-Detector)
$ErrorActionPreference = 'Continue'
$ev = Join-Path $PSScriptRoot '..\evidence'

function Invoke-Logged([string]$cmd) {
    "PS $env:COMPUTERNAME> $cmd"
    (Invoke-Expression $cmd | Out-String -Width 220).TrimEnd()
    ''
}

# ---------- 1. services.exe ----------
$svc = Get-Process -Name services
@(
    "# Lab 6 - services.exe facts on $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    ''
    Invoke-Logged "Get-Process -Id $($svc.Id) | Format-List Id, ProcessName, HandleCount, @{n='Threads';e={`$_.Threads.Count}}, @{n='WorkingSet(KB)';e={`$_.WorkingSet64/1KB}}, @{n='PrivateBytes(KB)';e={`$_.PrivateMemorySize64/1KB}}, @{n='PagedMemory(KB)';e={`$_.PagedMemorySize64/1KB}}, @{n='VirtualSize(MB)';e={[math]::Round(`$_.VirtualMemorySize64/1MB)}}, StartTime"
    Invoke-Logged "Get-CimInstance Win32_Process -Filter 'ProcessId=$($svc.Id)' | Format-List ProcessId, ParentProcessId, Name, HandleCount, ThreadCount, @{n='WorkingSet(KB)';e={`$_.WorkingSetSize/1KB}}, @{n='PrivatePageCount(KB)';e={`$_.PrivatePageCount/1KB}}"
    Invoke-Logged "Get-CimInstance Win32_Process -Filter 'ProcessId=$((Get-CimInstance Win32_Process -Filter "ProcessId=$($svc.Id)").ParentProcessId)' | Format-List ProcessId, ParentProcessId, Name    # the parent"
) | Set-Content -Path (Join-Path $ev 'windows-process-services.txt') -Encoding utf8

# ---------- 2. memory pressure ----------
function Get-Mem {
    $os = Get-CimInstance Win32_OperatingSystem
    $pf = Get-CimInstance Win32_PageFileUsage
    '{0}  RAM free {1,6:N0} MB of {2:N0} | commit used {3,6:N0} of {4:N0} MB | pagefile {5} MB allocated, {6} MB used' -f `
        (Get-Date -Format 'HH:mm:ss'),
        ($os.FreePhysicalMemory/1KB), ($os.TotalVisibleMemorySize/1KB),
        (($os.TotalVirtualMemorySize - $os.FreeVirtualMemory)/1KB), ($os.TotalVirtualMemorySize/1KB),
        ($pf | Measure-Object AllocatedBaseSize -Sum).Sum, ($pf | Measure-Object CurrentUsage -Sum).Sum
}
$start = Get-Date
$log = New-Object System.Collections.Generic.List[string]
$log.Add("# Lab 6 - memory pressure on $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$log.Add('')
$log.Add('######## BEFORE ########'); $log.Add((Get-Mem)); $log.Add('')
$log.Add('######## DURING - PowerShell allocates 100 MB blocks and touches every page ########')
$chunks = New-Object System.Collections.Generic.List[byte[]]
$mb = 0
try {
    while ($true) {
        $b = New-Object byte[] (100MB)
        for ($i = 0; $i -lt $b.Length; $i += 4096) { $b[$i] = 1 }
        $chunks.Add($b); $mb += 100
        if ($mb % 500 -eq 0) {
            $t = Measure-Command { Get-ChildItem C:\Windows | Out-Null }
            $log.Add(("allocated {0,5} MB | {1} | 'dir C:\Windows' took {2:N2} s" -f $mb, (Get-Mem), $t.TotalSeconds))
        }
        if (((Get-Date) - $start).TotalMinutes -gt 10) { $log.Add('stopped after 10 minutes'); break }
    }
} catch {
    $log.Add("allocation FAILED at $mb MB: $($_.Exception.GetType().Name): $($_.Exception.Message)")
}
$log.Add((Get-Mem))
$chunks.Clear(); $chunks = $null; [GC]::Collect()
Start-Sleep 5
$log.Add(''); $log.Add('######## AFTER (memory released) ########'); $log.Add((Get-Mem))
$log | Set-Content -Path (Join-Path $ev 'windows-memory-pressure.txt') -Encoding utf8

# ---------- 3. event log ----------
Start-Sleep 30   # the detector checks periodically
@(
    "# Lab 6 - Windows event log: low-memory events - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    ''
    Invoke-Logged "Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'; StartTime=[datetime]'$($start.ToString('s'))'} -ErrorAction SilentlyContinue | Format-List TimeCreated, Id, LevelDisplayName, ProviderName, Message"
    Invoke-Logged "Get-WinEvent -LogName 'Microsoft-Windows-Resource-Exhaustion-Detector/Operational' -MaxEvents 5 -ErrorAction SilentlyContinue | Format-List TimeCreated, Id, Message"
    Invoke-Logged "Get-WinEvent -FilterHashtable @{LogName='System'; Id=2004} -MaxEvents 3 -ErrorAction SilentlyContinue | Format-List TimeCreated, Id, ProviderName"
) | Set-Content -Path (Join-Path $ev 'windows-event-log-extract.txt') -Encoding utf8

Get-Content (Join-Path $ev 'windows-memory-pressure.txt') | Select-Object -Last 6
"`nEvent log extract:"; Get-Content (Join-Path $ev 'windows-event-log-extract.txt') | Select-Object -First 25
"`nSaved to $ev"
