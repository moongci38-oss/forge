# setup-windows-symlinks.ps1 — Windows symlink 생성 (관리자 권한 필요)
# 관리자 PowerShell에서 실행: powershell -ExecutionPolicy Bypass -File setup-windows-symlinks.ps1
#
# 이 스크립트는 Windows의 5개 디렉토리를 WSL 원본으로 향하는 symlink으로 교체한다.
# 실행 전 WSL에 실제 파일이 존재해야 한다 (sync-to-windows.sh 실행 후).

$ErrorActionPreference = "Stop"

$base = "C:\Users\moongci\.claude"
$wslBase = "\\wsl.localhost\Ubuntu-22.04\home\damools\.claude"
$dirs = @("agents", "commands", "rules", "skills", "prompts")

# Admin check
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Administrator privileges required." -ForegroundColor Red
    Write-Host "Right-click PowerShell -> Run as Administrator" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Windows Symlink Setup ===" -ForegroundColor Cyan
Write-Host "Base: $base"
Write-Host "WSL Target: $wslBase"
Write-Host ""

foreach ($dir in $dirs) {
    $src = "$base\$dir"
    $bak = "$base\${dir}_bak"
    $target = "$wslBase\$dir"

    Write-Host "Processing: $dir" -ForegroundColor Yellow

    # Check WSL target is accessible
    if (-not (Test-Path $target)) {
        Write-Host "  SKIP: WSL target not accessible ($target)" -ForegroundColor Red
        continue
    }

    # If already a symlink, skip
    $item = Get-Item $src -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq "SymbolicLink") {
        Write-Host "  SKIP: Already a symlink -> $($item.Target)" -ForegroundColor Green
        continue
    }

    # Backup existing directory
    if (Test-Path $src) {
        if (Test-Path $bak) {
            Remove-Item -Path $bak -Recurse -Force
        }
        Rename-Item -Path $src -NewName "${dir}_bak" -Force
        Write-Host "  Backed up to ${dir}_bak"
    }

    # Create symlink
    New-Item -ItemType SymbolicLink -Path $src -Target $target -Force | Out-Null
    Write-Host "  Symlink created: $src -> $target" -ForegroundColor Green

    # Verify
    $link = Get-Item $src
    if ($link.LinkType -eq "SymbolicLink") {
        $count = (Get-ChildItem $src -Force).Count
        Write-Host "  Verified: $count items accessible" -ForegroundColor Green

        # Remove backup
        if (Test-Path $bak) {
            Remove-Item -Path $bak -Recurse -Force
            Write-Host "  Backup removed"
        }
    } else {
        Write-Host "  FAILED: Restoring backup..." -ForegroundColor Red
        Remove-Item -Path $src -Force -ErrorAction SilentlyContinue
        if (Test-Path $bak) {
            Rename-Item -Path $bak -NewName $dir -Force
        }
    }

    Write-Host ""
}

Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To verify from WSL:" -ForegroundColor Yellow
Write-Host '  ls -la /mnt/c/Users/moongci/.claude/ | grep -E "agents|commands|rules|skills|prompts"'
