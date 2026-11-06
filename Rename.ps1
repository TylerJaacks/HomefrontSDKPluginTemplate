<#
Renames this template's mod from MyPlugin to your own name: the project, solution and script files, the namespace,
the class, the chat command and the CI workflow. Run it once after creating your repository from the template, then
delete it.

  .\Rename.ps1 -Name CoolMod
#>
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z_][A-Za-z0-9_]*$')]  # a C# identifier: it becomes the namespace and the DLL's name
    [string]$Name
)

$ErrorActionPreference = 'Stop'
$old = 'MyPlugin'
Set-Location $PSScriptRoot

if (-not (Test-Path "$old.csproj")) { throw "$old.csproj not found: already renamed?" }

$files = 'MyPlugin.csproj', 'MyPlugin.slnx', 'MyPlugin.cs', 'README.md', '.github\workflows\build.yml'
foreach ($f in $files) {
    $text = [IO.File]::ReadAllText((Resolve-Path $f))
    # "!myplugin" is the chat command, lower case like the SDK's own (!sdk, !bots).
    $text = $text.Replace($old, $Name).Replace($old.ToLowerInvariant(), $Name.ToLowerInvariant())
    [IO.File]::WriteAllText((Resolve-Path $f), $text)
}
foreach ($ext in 'csproj', 'slnx', 'cs') { Rename-Item "$old.$ext" "$Name.$ext" }
Remove-Item -Recurse -Force bin, obj -ErrorAction SilentlyContinue

Write-Host "renamed to $Name; delete Rename.ps1 and commit"
