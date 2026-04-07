# setup-windows-symlinks.ps1 - Windows .claude symlink setup (Admin required)
# Run in Admin PowerShell:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   & "\\wsl.localhost\Ubuntu-22.04\home\<wsluser>\forge\.claude\scripts\setup-windows-symlinks.ps1"

$ErrorActionPreference = "Stop"

# Auto-detect Windows user and WSL distro/user
$winUser = $env:USERNAME
$base = "C:\Users\$winUser\.claude"

$wslDistro = (wsl.exe -l -q 2>$null | Where-Object { $_ -match '\S' } | Select-Object -First 1).Trim() -replace "`0", ""
if (-not $wslDistro) {
    Write-Host "ERROR: WSL distro not found." -ForegroundColor Red
    exit 1
}

$wslUser = (wsl.exe -d $wslDistro -- whoami 2>$null).Trim()
if (-not $wslUser) {
    Write-Host "ERROR: WSL username not found." -ForegroundColor Red
    exit 1
}

$wslBase = "\\wsl.localhost\$wslDistro\home\$wslUser\.claude"
$wslForge = "\\wsl.localhost\$wslDistro\home\$wslUser\forge\dev"

# Admin check
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Administrator privileges required." -ForegroundColor Red
    exit 1
}

Write-Host "=== Windows .claude Symlink Setup ===" -ForegroundColor Cyan
Write-Host "Windows User : $winUser"
Write-Host "WSL Distro   : $wslDistro"
Write-Host "WSL User     : $wslUser"
Write-Host "Base         : $base"
Write-Host ""

# Create .claude dir if missing
if (-not (Test-Path $base)) {
    New-Item -ItemType Directory -Path $base -Force | Out-Null
    Write-Host "Created: $base" -ForegroundColor Green
}

# agents, commands, rules, skills, prompts symlinks
$dirs = @("agents", "commands", "rules", "skills", "prompts")

foreach ($dir in $dirs) {
    $src = "$base\$dir"
    $bak = "$base\${dir}_bak"
    $target = "$wslBase\$dir"

    Write-Host "$dir" -ForegroundColor Yellow

    if (-not (Test-Path $target)) {
        Write-Host "  SKIP: WSL target not found ($target)" -ForegroundColor Red
        continue
    }

    $item = Get-Item $src -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq "SymbolicLink") {
        Write-Host "  SKIP: Already a symlink" -ForegroundColor Green
        continue
    }

    try {
        if (Test-Path $src) {
            if (Test-Path $bak) { Remove-Item -Path $bak -Recurse -Force }
            Rename-Item -Path $src -NewName "${dir}_bak" -Force -ErrorAction Stop
            Write-Host "  Backed up to ${dir}_bak"
        }

        New-Item -ItemType SymbolicLink -Path $src -Target $target -Force | Out-Null

        $link = Get-Item $src
        if ($link.LinkType -eq "SymbolicLink") {
            $count = (Get-ChildItem $src -Force).Count
            Write-Host "  OK ($count items)" -ForegroundColor Green
            if (Test-Path $bak) { Remove-Item -Path $bak -Recurse -Force }
        }
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        if ((-not (Test-Path $src)) -and (Test-Path $bak)) {
            Rename-Item -Path $bak -NewName $dir -Force
            Write-Host "  Restored from backup" -ForegroundColor Yellow
        }
    }
}

# forge symlink
Write-Host ""
Write-Host "forge" -ForegroundColor Yellow

$forgeSrc = "$base\forge"
$forgeItem = Get-Item $forgeSrc -ErrorAction SilentlyContinue

if ($forgeItem) {
    Write-Host "  SKIP: Already exists" -ForegroundColor Green
} elseif (-not (Test-Path $wslForge)) {
    Write-Host "  SKIP: WSL ~/forge/dev not found" -ForegroundColor Red
    Write-Host "  Run in WSL first: git clone ssh://git@ssh.lumir-ai.com:32361/lumir/forge.git ~/forge" -ForegroundColor Yellow
} else {
    try {
        $result = cmd /c "mklink /D `"$forgeSrc`" `"$wslForge`"" 2>&1
        Write-Host "  OK: $forgeSrc -> $wslForge" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
$claudePath = "/mnt/c/Users/$winUser/.claude/"
Write-Host "Verify in WSL: ls -la $claudePath"
