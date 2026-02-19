# extract-portfolio-images.ps1
# Extract images per project-data-guide.md spec:
#   Thumbnail: {slug}-thumbnail.png (800x450)
#   Gallery:   {slug}-gallery-01.png ... {slug}-gallery-10.png (1920x1080)
#
# Usage: .\extract-portfolio-images.ps1 -ProjectFolder "albanow" -ProjectId "albanow"

param(
    [Parameter(Mandatory=$true)]  [string]$ProjectFolder,
    [Parameter(Mandatory=$true)]  [string]$ProjectId,
    [Parameter(Mandatory=$false)] [string]$BaseDir    = $(if ($env:PORTFOLIO_PROJECT) { $env:PORTFOLIO_PROJECT } else { "E:\portfolio_project" }),
    [Parameter(Mandatory=$false)] [string]$OutputBase = $(if ($env:BUSINESS_ROOT) { "$($env:BUSINESS_ROOT)\05-design\portfolio" } else { "Z:\home\damools\business\05-design\portfolio" })
)

Add-Type -AssemblyName System.Drawing

$sourceDir    = Join-Path $BaseDir $ProjectFolder
$outputDir    = Join-Path $OutputBase "images\$ProjectId"
$analysisDir  = Join-Path $OutputBase "_analysis"
$manifestPath = Join-Path $analysisDir "$ProjectId-images.json"
$excludePattern = "node_modules|\.git|dist|build|target|\.idea|\\bin\\|\\obj\\|__pycache__"

# Clean existing output folder before writing
if (Test-Path $outputDir) {
    Remove-Item -Path $outputDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $outputDir   | Out-Null
New-Item -ItemType Directory -Force -Path $analysisDir | Out-Null

# Find images: largest files first (screenshots > icons), skip SVG
$allImages = Get-ChildItem -Path $sourceDir -Recurse `
    -Include @("*.png","*.jpg","*.jpeg","*.gif","*.webp") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch $excludePattern } |
    Sort-Object Length -Descending |
    Select-Object -First 11

$manifestImages = [System.Collections.Generic.List[string]]::new()
$thumbnail = $null
$galleryIdx = 1

foreach ($img in $allImages) {
    $ext = $img.Extension.ToLower()
    $canResize = ($ext -eq ".png" -or $ext -eq ".jpg" -or $ext -eq ".jpeg")

    if ($null -eq $thumbnail) {
        # First image = thumbnail
        $destName = "$ProjectId-thumbnail.png"
        $destPath = Join-Path $outputDir $destName
        $relPath  = "images/$ProjectId/$destName"

        if ($canResize) {
            try {
                $src = [System.Drawing.Image]::FromFile($img.FullName)
                $dst = New-Object System.Drawing.Bitmap(800, 450)
                $g   = [System.Drawing.Graphics]::FromImage($dst)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.DrawImage($src, 0, 0, 800, 450)
                $g.Dispose(); $src.Dispose()
                $dst.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
                $dst.Dispose()
            } catch {
                Copy-Item $img.FullName $destPath -Force
            }
        } else {
            Copy-Item $img.FullName $destPath -Force
        }

        $thumbnail = $relPath
        $manifestImages.Add($relPath)

    } elseif ($galleryIdx -le 10) {
        # Remaining = gallery
        $idxStr   = $galleryIdx.ToString("D2")
        $destName = "$ProjectId-gallery-$idxStr.png"
        $destPath = Join-Path $outputDir $destName
        $relPath  = "images/$ProjectId/$destName"

        if ($canResize) {
            try {
                $src = [System.Drawing.Image]::FromFile($img.FullName)
                $dst = New-Object System.Drawing.Bitmap(1920, 1080)
                $g   = [System.Drawing.Graphics]::FromImage($dst)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.DrawImage($src, 0, 0, 1920, 1080)
                $g.Dispose(); $src.Dispose()
                $dst.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
                $dst.Dispose()
            } catch {
                Copy-Item $img.FullName $destPath -Force
            }
        } else {
            Copy-Item $img.FullName $destPath -Force
        }

        $manifestImages.Add($relPath)
        $galleryIdx++
    }
}

$galleryCount = $manifestImages.Count - $(if ($null -ne $thumbnail) { 1 } else { 0 })

$manifest = @{
    project_id  = $ProjectId
    images      = $manifestImages.ToArray()
    thumbnail   = $thumbnail
    total_count = $manifestImages.Count
}

$manifest | ConvertTo-Json -Depth 3 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host "DONE: $ProjectId - thumbnail:$(if($null -ne $thumbnail){'1'}else{'0'}) gallery:$galleryCount"
