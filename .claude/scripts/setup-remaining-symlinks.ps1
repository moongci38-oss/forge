# setup-remaining-symlinks.ps1 — skills, prompts만 처리
# 관리자 PowerShell: powershell -ExecutionPolicy Bypass -File C:\Users\moongci\Desktop\setup-remaining.ps1
# Claude Desktop 등 프로세스 종료 후 실행

$base = "C:\Users\moongci\.claude"
$wslBase = "\\wsl.localhost\Ubuntu-22.04\home\damools\.claude"
$dirs = @("skills", "prompts")

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Administrator privileges required." -ForegroundColor Red
    exit 1
}

foreach ($dir in $dirs) {
    $src = "$base\$dir"
    $bak = "$base\${dir}_bak"
    $target = "$wslBase\$dir"

    Write-Host "Processing: $dir" -ForegroundColor Yellow

    $item = Get-Item $src -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq "SymbolicLink") {
        Write-Host "  SKIP: Already a symlink" -ForegroundColor Green
        continue
    }

    if (-not (Test-Path $target)) {
        Write-Host "  SKIP: WSL target not accessible" -ForegroundColor Red
        continue
    }

    try {
        if (Test-Path $src) {
            if (Test-Path $bak) { Remove-Item -Path $bak -Recurse -Force }
            Rename-Item -Path $src -NewName "${dir}_bak" -Force -ErrorAction Stop
            Write-Host "  Backed up to ${dir}_bak"
        }

        New-Item -ItemType SymbolicLink -Path $src -Target $target -Force | Out-Null
        Write-Host "  Symlink created" -ForegroundColor Green

        $link = Get-Item $src
        if ($link.LinkType -eq "SymbolicLink") {
            $count = (Get-ChildItem $src -Force).Count
            Write-Host "  Verified: $count items" -ForegroundColor Green
            if (Test-Path $bak) { Remove-Item -Path $bak -Recurse -Force; Write-Host "  Backup removed" }
        }
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        if ((-not (Test-Path $src)) -and (Test-Path $bak)) {
            Rename-Item -Path $bak -NewName $dir -Force
            Write-Host "  Restored from backup" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

Write-Host "Done." -ForegroundColor Cyan
