# TFL.Powershell.Format-Task
Formats a task with additional information.

[![Build status](https://ci.appveyor.com/api/projects/status/g43d3owg3q1axaqk?svg=true)](https://ci.appveyor.com/project/TomBonnerAtTFL/tfl-powershell-format-task) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/TFL.Powershell.Format-Task.svg)](https://www.powershellgallery.com/packages/TFL.Powershell.Format-Task)

## Installation

```powershell
Install-Module TFL.Powershell.Format-Task -Scope CurrentUser -Force
```

## Usage

### Code

```powershell
Install-Module TFL.Powershell.Format-Task -Scope CurrentUser -Force

$length = Format-Task "Calculating Google's page size" {

    $request = Format-Task "Fetching Google's page" {
   
        return Invoke-WebRequest -Uri "https://google.com"
  
    } -NoResult

    return $request.RawContentLength
}

Write-Output "Google's front-page is $($length) bytes" 
```

### Output

```
Calculating Google's page size
-------------------------------------------------------------

    Fetching Google's page
    ---------------------------------------------------------
    Time: 623.11 ms
    Success: [√]

Result: 46622
Time: 639.79 ms
Success: [√]

Google's front-page is 46622 bytes

```

## Issues

If you find any bugs or wish to suggest improvement, please file an issue and consider sending a pull-request.
