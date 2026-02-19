# cleanup-images.ps1 — 매니페스트에 없는 이미지 삭제
param(
    [string]$PortfolioBase = $(if ($env:BUSINESS_ROOT) { "$($env:BUSINESS_ROOT)\05-design\portfolio" } else { "Z:\home\damools\business\05-design\portfolio" })
)

$analysisDir = Join-Path $PortfolioBase "_analysis"
$imagesBase  = Join-Path $PortfolioBase "images"

$manifests = Get-ChildItem -Path $analysisDir -Filter "*-images.json"

foreach ($mf in $manifests) {
    $data = Get-Content $mf.FullName | ConvertFrom-Json
    $pid  = $data.project_id

    Write-Host "[$pid] kept images:"
    foreach ($img in $data.images) { Write-Host "  $img" }

    $projectDir = Join-Path $imagesBase $pid
    if (-not (Test-Path $projectDir)) {
        Write-Host "[$pid] images folder not found, skip."
        continue
    }

    # 유지할 파일명 목록 (경로에서 파일명만)
    $keepNames = @()
    foreach ($img in $data.images) {
        $keepNames += [System.IO.Path]::GetFileName($img)
    }

    # 폴더 내 모든 파일 순회 → 매니페스트에 없으면 삭제
    $all   = Get-ChildItem -Path $projectDir -File
    $del   = 0
    foreach ($file in $all) {
        if ($keepNames -notcontains $file.Name) {
            Remove-Item -Path $file.FullName -Force
            $del++
        }
    }
    Write-Host "[$pid] deleted $del files, kept $($keepNames.Count)"
}
Write-Host "=== Cleanup Done ==="
