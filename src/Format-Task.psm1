#   Copyright 2018 Transport for London

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

function Write-Good {

    $green = @{
        Object = [Char]8730
        ForegroundColor = "Green"
        NoNewLine = $true
    }

    Write-Information -NoNewLine "["
    Write-Information @green
    Write-Information -NoNewline "]"
}

function Write-Bad {

    <#
    .Synopsis
    Writes a negative output
    .Description
    Writes a negative output with an exception message
    #>
    param (
        [String]
        $exceptionMessage
    )
    
    $red = @{
        Object = "x"
        ForegroundColor = "Red"
        NoNewLine = $true
    }

    Write-Information -NoNewLine "["
    Write-Information @red
    Write-Information "] `($($exceptionMessage)`)" -NoNewline
}

function AreWeNotVSTS
{
    return $false
    
    # We should consider acting differently based on other environments
    # return $env:VSTS_PROCESS_LOOKUP_ID -eq $null
}


function Format-ElapsedTimeString
{
    <#
    .Synopsis
    Formats the elapsed time object
    #>
    param (
        [TimeSpan]
        $timeSpan
    )

    # TODO: Make this scale better to longer times
    return "$([System.Math]::Round($timeSpan.TotalMilliseconds, 2)) ms"
}

function Format-Task
{
    <#
    .Synopsis
    Formats a sub-task neatly
    .Description
    Formats a sub-task neatly with additional output and better handling of returned objects and exceptions    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [String]
        $Message,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $false)]
        [switch]
        $NoResult,

        [Parameter(Mandatory = $false)]
        [switch]
        $NoReturn
    )

    $pre = $ErrorActionPreference

    if (-Not ($script:TabLevel)) {
        $script:TabLevel = 0
    }

    $tabPrefix = "    " * $script:TabLevel

    $ret = $null

    $dots = "-" * ([Math]::Max($message.Length, $host.UI.RawUI.BufferSize.Width) - ($tabPrefix.Length))

    $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch

    try
    {
        $script:TabLevel = $script:TabLevel + 1

        # Override the error-action to help us pick up exceptions
        $ErrorActionPreference = "Stop"
        
        # Print header
        if (AreWeNotVSTS -and $host.UI.SupportsVirtualTerminal) {
            Write-Information "$($tabPrefix)$($Message): " -NoNewline
            $origPos = $host.UI.RawUI.CursorPosition
            Write-Information
        } else {
            Write-Information
            Write-Information "$($tabPrefix)$($Message)"
            Write-Information "$($tabPrefix)$($dots)"
        }

        # Execute the script
        $stopWatch.Start()
        $ret = Invoke-Command -ScriptBlock $ScriptBlock
        $stopWatch.Stop()

        # Derive the time-taken
        $elapsedTime = Format-ElapsedTimeString $stopWatch.Elapsed

        # Print footer
        if (AreWeNotVSTS -and $host.UI.SupportsVirtualTerminal) {
            $pre = $host.UI.RawUI.CursorPosition
            $host.UI.RawUI.CursorPosition = $origPos

            Write-Good

            if ($ret -ne $null -and ($noResult -eq $false)) {
                Write-Information " - Result: $($ret), Time: $($elapsedTime)"
            }

            $host.UI.RawUI.CursorPosition = $pre

            
        } else {
            
            # If there is a result, and we are supposed to output it
            if ($ret -ne $null -and ($NoResult -eq $false)) {
                Write-Information "$($tabPrefix)Result: $($ret)"
            }

            Write-Information "$($tabPrefix)Time: $($elapsedTime)"
            Write-Information "$($tabPrefix)Success: " -NoNewline
            Write-Good
            Write-Information
            Write-Information
        }

        if ($NoReturn) {
            return
        } else {
            return $ret
        }
    }
    catch
    {
        $stopWatch.Stop()

        # Derive the time-taken
        $elapsedTime = Format-ElapsedTimeString $stopWatch.Elapsed

        # Print footer
        if (AreWeNotVSTS -and $host.UI.SupportsVirtualTerminal) {
            $pre = $host.UI.RawUI.CursorPosition
            $host.UI.RawUI.CursorPosition = $origPos

            Write-Bad $_.Exception
            
            Write-Information " - Time: $($elapsedTime)"
            
            $host.UI.RawUI.CursorPosition = $pre
        } else {

            Write-Information "$($tabPrefix)Time: $($elapsedTime)"
            Write-Information "$($tabPrefix)Fail: " -NoNewline
            Write-Bad $_.Exception
            Write-Information
            Write-Information
        }

        throw
    }
    finally {
        $ErrorActionPreference = $pre
        $script:TabLevel = $script:TabLevel - 1
    }
}

Export-ModuleMember -Function Format-Task