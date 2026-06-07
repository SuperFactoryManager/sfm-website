param(
    [string]$SourcePath = "..\\static"
)

$resolvedSourcePath = Resolve-Path -LiteralPath $SourcePath

Write-Host "Uploading static site files from $resolvedSourcePath"
Write-Host "Target storage account: sfmwebsiteprod"
Write-Host "Target container: webcontent"

az storage blob upload-batch `
    --account-name "sfmwebsiteprod" `
    --auth-mode login `
    --source $resolvedSourcePath `
    --destination "webcontent" `
    --overwrite true
