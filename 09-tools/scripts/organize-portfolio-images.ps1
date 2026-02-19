# organize-portfolio-images.ps1
# 포트폴리오 프로젝트 이미지를 가이드 규격에 맞게 정리
# - 썸네일: {slug}-thumbnail.png (800x450px)
# - 갤러리: {slug}-gallery-01.png, gallery-02.png ... (1920x1080px, 최대 10장)
# Usage: .\organize-portfolio-images.ps1 -ProjectFolder "albanow" -ProjectId "albanow" -BaseDir "E:\portfolio_project"

param(
    [Parameter(Mandatory=$true)]  [string]$ProjectFolder,
    [Parameter(Mandatory=$true)]  [string]$ProjectId,
    [Parameter(Mandatory=$false)] [string]$BaseDir    = "E:\portfolio_project",
    [Parameter(Mandatory=$false)] [string]$OutputBase = "Z:\home\damools\business\05-design\portfolio"
)

Add-Type -AssemblyName System.Drawing

$sourceDir    = Join-Path $BaseDir $ProjectFolder
$outputDir    = Join-Path $OutputBase "images\$ProjectId"
$analysisDir  = Join-Path $OutputBase "_analysis"
$manifestPath = Join-Path $analysisDir "$ProjectId-images.json"

$excludePattern = "node_modules|\.git|dist|build|target|\.idea|\\bin\\|\\obj\\|__pycache__"
$extensions     = @("*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp")  # svg 제외 (렌더링 불안정)

# 기존 출력 폴더 비우고 재생성
if (Test-Path $outputDir) { Remove-Item $outputDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $analysisDir | Out-Null

# 이미지 탐색 (제외 폴더 필터, SVG 제외)
$rawImages = Get-ChildItem -Path $sourceDir -Recurse -Include $extensions -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch $excludePattern } |
    Where-Object { $_.Extension -ne ".svg" } |
    Sort-Object Length -Descending   # 큰 파일 우선 (스크린샷이 아이콘보다 큼)

function Resize-Image {
    param(
        [string]$SrcPath,
        [string]$DstPath,
        [int]$Width,
        [int]$Height
    )
    try {
        $src = [System.Drawing.Image]::FromFile($SrcPath)

        # 비율 유지 letterbox 리사이즈
        $srcRatio = $src.Width / $src.Height
        $dstRatio = $Width / $Height

        if ($srcRatio -gt $dstRatio) {
            # 가로가 더 넓음 → 가로에 맞추고 세로 패딩
            $drawW = $Width
            $drawH = [int]($Width / $srcRatio)
            $offsetX = 0
            $offsetY = [int](($Height - $drawH) / 2)
        } else {
            # 세로가 더 길음 → 세로에 맞추고 가로 패딩
            $drawH = $Height
            $drawW = [int]($Height * $srcRatio)
            $offsetX = [int](($Width - $drawW) / 2)
            $offsetY = 0
        }

        $canvas = New-Object System.Drawing.Bitmap($Width, $Height)
        $g = [System.Drawing.Graphics]::FromImage($canvas)
        $g.Clear([System.Drawing.Color]::Black)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($src, $offsetX, $offsetY, $drawW, $drawH)
        $g.Dispose()
        $src.Dispose()

        # PNG로 저장 (WebP는 .NET 기본 미지원)
        $canvas.Save($DstPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $canvas.Dispose()
        return $true
    } catch {
        return $false
    }
}

$copiedPaths = [System.Collections.Generic.List[string]]::new()
$thumbnail   = $null

# ── 썸네일: 첫 번째 이미지 (800x450) ──
if ($rawImages.Count -gt 0) {
    $firstImg = $rawImages[0]
    $dstName  = "$ProjectId-thumbnail.png"
    $dstPath  = Join-Path $outputDir $dstName
    $ok = Resize-Image -SrcPath $firstImg.FullName -DstPath $dstPath -Width 800 -Height 450
    if ($ok -eq $true) {
        $thumbnail = "images/$ProjectId/$dstName"
        $copiedPaths.Add($thumbnail)
    }
}

# ── 갤러리: 2번째~11번째 이미지 (1920x1080, 최대 10장) ──
$galleryImgs = $rawImages | Select-Object -Skip 1 -First 10
$idx = 1
foreach ($img in $galleryImgs) {
    $dstName = "$ProjectId-gallery-{0:D2}.png" -f $idx
    $dstPath = Join-Path $outputDir $dstName
    $ok = Resize-Image -SrcPath $img.FullName -DstPath $dstPath -Width 1920 -Height 1080
    if ($ok -eq $true) {
        $copiedPaths.Add("images/$ProjectId/$dstName")
        $idx++
    }
}

# 매니페스트 JSON 업데이트
$manifest = @{
    project_id  = $ProjectId
    images      = $copiedPaths
    thumbnail   = $thumbnail
    total_count = $copiedPaths.Count
}
$manifest | ConvertTo-Json -Depth 3 | Set-Content -Path $manifestPath -Encoding UTF8

$thumbStatus  = if($thumbnail){'O'}else{'X'}
$galleryCount = $idx - 1
Write-Host "DONE: $ProjectId -- thumb=$thumbStatus, gallery=$galleryCount"
