# TFL.Powershell.Format-Task
Formats a task with additional information.

## Installation

```
Install-Module TFL.Powershell.Format-Task -Scope CurrentUser -Force
```

## Usage

### Code

```
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
