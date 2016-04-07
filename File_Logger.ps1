$getMonthYear = Get-Date -Format "yyyy-MMMM"
$logFile = ".\$getMonthYear.txt"
$localCompName = (get-wmiobject win32_computersystem -property Name).Name
$timeAndDate = Get-Date -Format "dd-MMM-yyyy HH:mm"
$DebugPreference = "Continue"

Function listLog {
    Get-ChildItem -Exclude *.ps1 | Format-Table LastWriteTime, `
    @{Name="Log Name";Expression={$_.name}}
    runMenu
}

Function openLog {
    Write-Host "`nWhat file do you want to open?"
    $fileSel = Read-Host "LogFile"

    Try {
        Invoke-Item .\$fileSel -ErrorAction stop
        Write-Host "`nOpening file $fileSel"
    } Catch {
        Write-Warning "Filename not found"
        Write-Debug "Did you enter the file ending?`n"
        runMenu
    }
}

Function runMenu {
    Write-Host "1. Run Logger"
    Write-Host "2. List Logs"
    Write-Host "3. Open Log"
    Write-Host "4. Close Process"
    $menuC = Read-Host "`nNumber"

    switch ($menuC) {
        1 {log; break}
        2 {listLog; break}
        3 {openlog;break}
        4 {break}
        default {"Invalid Input / NaN"; break}
    }
}

Function log {
    Write-Output "`n-----------------------------------------" | Out-File $logFile -Append
    Write-Output "Computer Name:    $localCompName"  | Out-File $logFile -Append
    Write-Output "Time & Date:      $timeAndDate" | Out-File $logFile -Append

    Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
        | Format-Table DeviceID, `
        @{Name="Size(GB)";Expression={[decimal]("{0:N0}" -f($_.size/1gb))}}, `
        @{Name="Free Space(GB)";Expression={[decimal]("{0:N0}" -f($_.freespace/1gb))}}, ` `
        @{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}} `
        -AutoSize | Out-File $logFile -Append

    Write-Host "Logger ran`n"
    runMenu
}

Clear-Host
log
runMenu