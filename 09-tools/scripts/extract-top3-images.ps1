# extract-top3-images.ps1 — 프로젝트당 대표 이미지 3장 추출
param(
    [string]$BaseDir    = "E:\portfolio_project",
    [string]$OutputBase = "Z:\home\damools\business\05-design\portfolio"
)

$exts    = @("*.png","*.jpg","*.jpeg")
$exclude = "node_modules|\.git|dist|build|target|__pycache__"

$projects = @(
    @{folder="albanow";           id="albanow"},
    @{folder="clayon source";     id="clayon-source"},
    @{folder="Crawling";          id="crawling"},
    @{folder="exchange_kodaqs";   id="exchange-kodaqs"},
    @{folder="mukja";             id="mukja"},
    @{folder="NCLSource";         id="ncl-source"},
    @{folder="nice_i";            id="nice-i"},
    @{folder="pin_key";           id="pin-key"},
    @{folder="samsungmall";       id="samsungmall"},
    @{folder="SmartDoor";         id="smart-door"},
    @{folder="starmario-develop"; id="starmario-develop"}
)

foreach ($p in $projects) {
    $src    = Join-Path $BaseDir $p.folder
    $outDir = Join-Path $OutputBase "images\$($p.id)"
    $mDir   = Join-Path $OutputBase "_analysis"

    New-Item -ItemType Directory -Force -Path $outDir | Out-Null

    $imgs = Get-ChildItem -Path $src -Recurse -Include $exts -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $exclude } |
        Sort-Object Length -Descending |
        Select-Object -First 3

    $copied = @()
    $thumb  = $null

    foreach ($img in $imgs) {
        $dest = Join-Path $outDir $img.Name
        Copy-Item -Path $img.FullName -Destination $dest -Force
        $rel = "images/$($p.id)/$($img.Name)"
        $copied += $rel
        if (-not $thumb) { $thumb = $rel }
    }

    $manifest = @{
        project_id  = $p.id
        images      = $copied
        thumbnail   = $thumb
        total_count = $copied.Count
    }
    $manifest | ConvertTo-Json -Depth 3 |
        Set-Content (Join-Path $mDir "$($p.id)-images.json") -Encoding UTF8

    Write-Host "DONE: $($p.id) - $($copied.Count) images"
}
