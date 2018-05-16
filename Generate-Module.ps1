if (Test-Path ".\deploy") {
    Add-AppveyorMessage "Deleting previous deployment directory"        
    Remove-Item ".\deploy" -Force -Recurse
}

if (Test-Path ".\staging") {
    Add-AppveyorMessage "Deleting previous staging directory"    
    Remove-Item ".\staging" -Force -Recurse
}

# Properties
$functionsToExport = $Env:FunctionsToExport -split ";"
$tags = $Env:Tags -split ";"

$stagingDirectory = New-Item ".\staging" -ItemType Directory -Force

Add-AppveyorMessage "Installing Formatter"
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force

Add-AppveyorMessage "Copying and cleaning code"
Get-ChildItem -Path "src" -Filter "*.psm1" | ForEach-Object {Invoke-Formatter -ScriptDefinition (Get-Content $_.FullName -Raw) >> (Join-Path -Path $stagingDirectory.FullName $_.Name) }

$file = Get-ChildItem -Path $stagingDirectory -Filter "*.psm1"
if ($file -eq $null) {
    throw "Could not find *.psm1"
}

Add-AppveyorMessage "Generating manifest"
$psdFile = Join-Path -Path $stagingDirectory -ChildPath "$($Env:ModuleName).psd1"
New-ModuleManifest -Path $psdFile -Description $Env:Description -Author $Env:Author -Copyright $Env:Copyright -CompanyName $Env:Company -ModuleVersion $Env:APPVEYOR_BUILD_VERSION -RootModule $file.Name -FunctionsToExport $functionsToExport -ProjectUri $Env:ProjectUri -LicenseUri $Env:LicenseUri -Tags $tags

Add-AppveyorMessage "Copying misc files"
Copy-Item -Path "LICENSE" -Destination $stagingDirectory
Copy-Item -Path "README.md" -Destination $stagingDirectory

# Add-AppveyorMessage "Generating documentation"
# Install-Module -Name platyPS -Scope CurrentUser -Force
# New-ExternalHelp .\docs -OutputPath en-GB\
# Copy-Item -Path "en-GB" -Destination $stagingDirectory

# Removed because Install-Module fails with an unsigned catalog
# Add-AppveyorMessage "Generating catalog"
# New-FileCatalog -Path $stagingDirectory -CatalogFilePath (Join-Path -Path $stagingDirectory -ChildPath "$($Env:ModuleName).cat")

$tempNugetRepo = New-Item -ItemType Directory ".\nuget-feed\nuget\v2"
$deploymentDirectory = New-Item -ItemType Directory ".\deploy"

try
{
    Add-AppveyorMessage "Bootstrapping NuGet"
    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
    
    Add-AppveyorMessage "Registering temp repository"    
    Register-PSRepository -Name "temp" -SourceLocation $tempNugetRepo.FullName

    Add-AppveyorMessage "Publishing module to temp repository"
    Publish-Module -Name $psdFile -Repository "temp"

    $package = Get-ChildItem -Filter "*.nupkg" -Recurse

    Add-AppveyorMessage "Moving package to output"
    Move-Item -Path $package.FullName -Destination $deploymentDirectory.FullName
}
finally 
{
    Add-AppveyorMessage "Deleting temp resources"
    Unregister-PSRepository "temp" -ErrorAction SilentlyContinue
    Remove-Item -Path (Get-Item "nuget-feed") -Recurse -Force
}
