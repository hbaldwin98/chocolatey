param (
    [switch]$ignore,
    [string[]]$only,
    [string[]]$types
)

# Install Chocolatey (if not already installed)
if (!(Test-Path "$env:ProgramData\chocolatey\choco.exe")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
}

$programsJson = Get-Content -Raw -Path "$PSScriptRoot\scripts.json"
$programs = ConvertFrom-Json $programsJson

# Filter programs based on flags
if ($ignore) {
    $programs = $programs | Where-Object { $only.ToLower() -notcontains $_.name.ToLower() }
}
elseif ($only) {
    $programs = $programs | Where-Object { $only.ToLower() -contains $_.name.ToLower()}
}

if ($types) {
    $programs = $programs | Where-Object { $types.ToLower() -contains $_.type.ToLower() }
}

# Check if programs are already installed
$installedPrograms = Get-WmiObject -Query "SELECT * FROM Win32_Product" | Select-Object -ExpandProperty Name

Write-Host "Installing programs..."

foreach ($program in $programs) {
    if ($installedPrograms -contains $program.packageName.ToLower()) {
        Write-Host "$($program.name) is already installed."
    }
    else {
        Write-Host "Installing $($program.name)..."
        choco install $program.packageName -y
    }
}