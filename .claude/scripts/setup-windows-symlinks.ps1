# setup-windows-symlinks.ps1 — Windows .claude symlink 생성 (관리자 권한 필요)
# 관리자 PowerShell에서 실행:
#   powershell -ExecutionPolicy Bypass -File "C:\path\to\setup-windows-symlinks.ps1"
#
# 자동으로 현재 Windows 사용자명과 WSL 배포판/유저를 감지한다.
# agents, commands, rules, skills, prompts → WSL ~/.claude/ 심볼릭
# forge → WSL ~/forge/dev 심볼릭

$ErrorActionPreference = "Stop"

# ─── 사용자/WSL 자동 감지 ───────────────────────────────────────────────────

$winUser = $env:USERNAME
$base = "C:\Users\$winUser\.claude"

# WSL 기본 배포판 감지
$wslDistro = (wsl.exe -l -q 2>$null | Where-Object { $_ -match '\S' } | Select-Object -First 1).Trim() -replace "`0", ""
if (-not $wslDistro) {
    Write-Host "ERROR: WSL 배포판을 찾을 수 없습니다." -ForegroundColor Red
    exit 1
}

# WSL 사용자명 감지
$wslUser = (wsl.exe -d $wslDistro -- whoami 2>$null).Trim()
if (-not $wslUser) {
    Write-Host "ERROR: WSL 사용자명을 가져올 수 없습니다." -ForegroundColor Red
    exit 1
}

$wslBase = "\\wsl.localhost\$wslDistro\home\$wslUser\.claude"
$wslForge = "\\wsl.localhost\$wslDistro\home\$wslUser\forge\dev"

# ─── Admin check ────────────────────────────────────────────────────────────

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: 관리자 권한이 필요합니다." -ForegroundColor Red
    Write-Host "PowerShell을 '관리자 권한으로 실행' 후 재시도하세요." -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Windows .claude Symlink Setup ===" -ForegroundColor Cyan
Write-Host "Windows User : $winUser"
Write-Host "WSL Distro   : $wslDistro"
Write-Host "WSL User     : $wslUser"
Write-Host "Base         : $base"
Write-Host ""

# ─── .claude 디렉토리 생성 ──────────────────────────────────────────────────

if (-not (Test-Path $base)) {
    New-Item -ItemType Directory -Path $base -Force | Out-Null
    Write-Host "Created: $base`n" -ForegroundColor Green
}

# ─── agents, commands, rules, skills, prompts 심볼릭 ────────────────────────

$dirs = @("agents", "commands", "rules", "skills", "prompts")

foreach ($dir in $dirs) {
    $src = "$base\$dir"
    $bak = "$base\${dir}_bak"
    $target = "$wslBase\$dir"

    Write-Host "[$dir]" -ForegroundColor Yellow

    if (-not (Test-Path $target)) {
        Write-Host "  SKIP: WSL 타겟 없음 ($target)" -ForegroundColor Red
        continue
    }

    $item = Get-Item $src -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq "SymbolicLink") {
        Write-Host "  SKIP: 이미 심볼릭 -> $($item.Target)" -ForegroundColor Green
        continue
    }

    try {
        if (Test-Path $src) {
            if (Test-Path $bak) { Remove-Item -Path $bak -Recurse -Force }
            Rename-Item -Path $src -NewName "${dir}_bak" -Force -ErrorAction Stop
            Write-Host "  백업: ${dir}_bak"
        }

        New-Item -ItemType SymbolicLink -Path $src -Target $target -Force | Out-Null

        $link = Get-Item $src
        if ($link.LinkType -eq "SymbolicLink") {
            $count = (Get-ChildItem $src -Force).Count
            Write-Host "  OK: $src -> $target ($count items)" -ForegroundColor Green
            if (Test-Path $bak) { Remove-Item -Path $bak -Recurse -Force }
        }
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        if ((-not (Test-Path $src)) -and (Test-Path $bak)) {
            Rename-Item -Path $bak -NewName $dir -Force
            Write-Host "  백업 복원됨" -ForegroundColor Yellow
        }
    }
}

# ─── forge 심볼릭 ───────────────────────────────────────────────────────────

Write-Host ""
Write-Host "[forge]" -ForegroundColor Yellow

$forgeSrc = "$base\forge"
$forgeItem = Get-Item $forgeSrc -ErrorAction SilentlyContinue

if ($forgeItem) {
    Write-Host "  SKIP: 이미 존재 ($forgeSrc)" -ForegroundColor Green
} elseif (-not (Test-Path $wslForge)) {
    Write-Host "  SKIP: WSL ~/forge/dev 없음" -ForegroundColor Red
    Write-Host "  → WSL에서 먼저 실행: git clone <forge-repo> ~/forge" -ForegroundColor Yellow
} else {
    try {
        cmd /c "mklink /D `"$forgeSrc`" `"$wslForge`"" | Out-Null
        Write-Host "  OK: $forgeSrc -> $wslForge" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "검증 (WSL에서):" -ForegroundColor Yellow
Write-Host "  ls -la /mnt/c/Users/$winUser/.claude/"
