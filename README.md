# TFL.Powershell.Format-Task
Formats a task with additional information.

This can be found on PowerShell Gallery here: https://www.powershellgallery.com/packages/TFL.Powershell.Format-Task

[![Build status](https://ci.appveyor.com/api/projects/status/g43d3owg3q1axaqk?svg=true)](https://ci.appveyor.com/project/TomBonnerAtTFL/tfl-powershell-format-task) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/TFL.Powershell.Format-Task.svg)](https://www.powershellgallery.com/packages/TFL.Powershell.Format-Task)

## Installation

```powershell
Install-Module TFL.Powershell.Format-Task -Scope CurrentUser -Force
```

## Usage

### Code

```powershell
Install-Module TFL.Powershell.Format-Task -Scope CurrentUser -Force

$length = Format-Task "Calculating Example's page size" {

    $request = Format-Task "Fetching Example's page" {
   
        return Invoke-WebRequest -Uri "https://example.com"
  
    } -NoResult

    return $request.RawContentLength
}

Write-Output "Example's front-page is $($length) bytes" 
```

### Output

```
Calculating Example's page size
----------------------------------------------------------

    Fetching Example's page
    ------------------------------------------------------
    Time: 449.25 ms
    Success: [√]

Result: 1270
Time: 563.56 ms
Success: [√]

Example's front-page is 1270 bytes
```

## Issues

If you find any bugs or wish to suggest improvement, please file an issue and consider sending a pull-request.
