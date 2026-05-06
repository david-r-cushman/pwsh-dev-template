$ErrorActionPreference = 'Stop'

function Import-TemplateModuleFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BasePath
    )

    foreach ($folderName in @('Private', 'Public')) {
        $folderPath = Join-Path -Path $BasePath -ChildPath $folderName
        if (-not (Test-Path -LiteralPath $folderPath)) {
            continue
        }

        $files = Get-ChildItem -LiteralPath $folderPath -Filter '*.ps1' -File -ErrorAction Stop
        foreach ($file in $files) {
            . $file.FullName
        }
    }
}

Import-TemplateModuleFile -BasePath $PSScriptRoot

$publicFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
if (Test-Path -LiteralPath $publicFolder) {
    $publicFunctionNames = Get-ChildItem -LiteralPath $publicFolder -Filter '*.ps1' -File -ErrorAction Stop |
        ForEach-Object { $_.BaseName }

    if ($publicFunctionNames) {
        Export-ModuleMember -Function $publicFunctionNames
    }
}
