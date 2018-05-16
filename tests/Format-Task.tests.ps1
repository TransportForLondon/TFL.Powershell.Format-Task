$targetDirectory = $null

if (Test-Path -Path "staging") {
    $targetDirectory = Get-ChildItem "staging"
} elseif (Test-Path -Path "src") {
    $targetDirectory = Get-ChildItem "src"
}

if ($targetDirectory -eq $null) { 
    Throw "Could not find source-directory" 
}

$scanFiles = Get-ChildItem -Path $targetDirectory -Recurse -Filter "*.psm1"

$scanFiles | ForEach-Object {

    Describe "Testing $($_.Name) against PSSA rules" {
        $analysis = Invoke-ScriptAnalyzer -Path $_.FullName -Recurse
    
        forEach ($failure in $analysis) {
    
            It "$($failure.ScriptName)#$($failure.Line) should pass $($failure.RuleName)" {
                throw $failure.Message
            }
        }
    }
}