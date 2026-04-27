param(
    [Parameter()]
    [string]$Publisher,

    [Parameter()]
    [string]$ExtensionName,

    [Parameter()]
    [string]$ExtensionLink,

    [Parameter()]
    [string]$Version,

    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [switch]$Help
)

function Print-Help {
    Write-Host @"
Snag That Extension! - Downloads the VSIX file from the VS Code Extension Marketplace for offline install

Usage:
  snag-that-ext.ps1 -Publisher PUBLISHER -ExtensionName EXTENSION_NAME `
                    [-Version VERSION] [-OutputPath OUTPUT_DIR]

  snag-that-ext.ps1 -ExtensionLink MARKETPLACE_URL `
                    [-Version VERSION] [-OutputPath OUTPUT_DIR]

Arguments:
  -Publisher       Required unless -ExtensionLink is used
  -ExtensionName   Required unless -ExtensionLink is used
  -ExtensionLink   Optional, Marketplace URL, takes precedence over -Publisher and -ExtensionName if all provided

  -Version         Optional, defaults to 'latest'
  -OutputPath      Optional, directory to save the VSIX (defaults to working directory)
  -Help            Display this message
"@
}

# Show help if no parameters or Help flag
if ($Help -or $PSBoundParameters.Count -eq 0) {
    Print-Help
    return
}

# Parse ExtensionLink if provided
if ($ExtensionLink) {
    if ($ExtensionLink -match 'itemName=([^&]+)') {
        $itemName = $Matches[1]

        if ($itemName -notmatch '\.') {
            Write-Error "Invalid ExtensionLink: itemName must be in the form Publisher.ExtensionName"
            return
        }

        $linkPublisher, $linkExtensionName = $itemName -split '\.', 2

        if (-not $Publisher) {
            $Publisher = $linkPublisher
        }
        if (-not $ExtensionName) {
            $ExtensionName = $linkExtensionName
        }
    }
    else {
        Write-Error "Invalid ExtensionLink: unable to find itemName parameter"
        return
    }
}

# Validate required parameters
if (-not ($Publisher -and $ExtensionName)) {
    Write-Error "Publisher and ExtensionName must be provided, either directly or via -ExtensionLink."
    Print-Help
    return
}

if (-not $Version) {
    $Version = "latest"
    Write-Host "Version not provided, snagging latest version"
}

if (-not $OutputPath) {
    $OutputPath = $PWD.Path
}

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

$vsixFile = "$Publisher.$ExtensionName.$Version.vsix"
$outputFile = Join-Path $OutputPath $vsixFile

$url = "https://$Publisher.gallery.vsassets.io/_apis/public/gallery/publisher/$Publisher/extension/$ExtensionName/$Version/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

try {
    Invoke-WebRequest -Uri $url -OutFile $outputFile -ErrorAction Stop
    Write-Host "Extension $ExtensionName downloaded successfully."
}
catch {
    Write-Error "An error occurred while trying to download the file: $_"
}