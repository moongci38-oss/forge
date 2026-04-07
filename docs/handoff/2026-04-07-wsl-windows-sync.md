# WSL/Windows .claude 동기화 구조 정비 (2026-04-07)

## 배경

팀원이 forge를 받아도 Windows Claude Code에서 동일한 설정(rules, skills, agents 등)이 보이지 않는 문제가 있었다.
원인: WSL `.claude/` 설정이 Windows `.claude/`와 심볼릭으로 연결되어 있지 않았고, 온보딩 스크립트가 하드코딩되어 있었음.

---

## .claude 디렉토리 구조

```
WSL: ~/.claude/
├── agents/          ← 실제 파일 (forge-sync으로 배포됨)
├── commands/        ← 실제 파일
├── rules/           ← 실제 파일
├── skills/          ← 실제 파일
├── prompts/         ← 실제 파일
├── forge -> ~/forge/dev   ← 심볼릭 (setup-mcp.sh가 생성)
└── scripts/         ← forge-sync, setup 스크립트 등

Windows: C:\Users\{username}\.claude\
├── agents    -> \\wsl.localhost\{distro}\home\{wsluser}\.claude\agents   (SYMLINKD)
├── commands  -> \\wsl.localhost\{distro}\home\{wsluser}\.claude\commands  (SYMLINKD)
├── rules     -> \\wsl.localhost\{distro}\home\{wsluser}\.claude\rules     (SYMLINKD)
├── skills    -> \\wsl.localhost\{distro}\home\{wsluser}\.claude\skills    (SYMLINKD)
├── prompts   -> \\wsl.localhost\{distro}\home\{wsluser}\.claude\prompts   (SYMLINKD)
└── forge     -> \\wsl.localhost\{distro}\home\{wsluser}\forge\dev         (SYMLINKD)
```

Windows Claude Code에서 skills/rules 읽을 때 → 심볼릭 → WSL 실제 파일 참조
→ WSL만 업데이트하면 Windows도 자동 동기화

---

## 변경 내용

### setup-mcp.sh 수정
- **경로**: `shared/scripts/setup-mcp.sh`
- **커밋**: `0ae2511`
- **내용**: `~/.claude/forge → ~/forge/dev` 심볼릭 자동 생성 로직 추가 (멱등성 보장)
- forge-sync가 `~/.claude/forge`를 기준으로 동작하므로 이 심볼릭이 반드시 필요

### setup-windows-symlinks.ps1 개선
- **경로**: `.claude/scripts/setup-windows-symlinks.ps1`
- **커밋**: `66fff2e`, `540f07a`
- **내용**:
  - 하드코딩된 `moongci`/`damools` 제거
  - `$env:USERNAME`으로 Windows 유저 자동 감지
  - `wsl.exe -l -q` / `wsl whoami`로 WSL 배포판·유저 자동 감지
  - `forge` 심볼릭(`mklink /D`) 생성 로직 추가

### README 온보딩 가이드 추가
- **경로**: `README.md`
- **커밋**: `45c2aa5`
- **내용**: WSL+Windows 심볼릭 설정 단계 추가 (Step 6)

---

## 팀원 온보딩 절차

### WSL (최초 1회)
```bash
cd ~/forge && git pull
bash shared/scripts/setup-mcp.sh
# → ~/.claude/forge 심볼릭 생성 + MCP 서버 등록
```

### Windows (최초 1회, 관리자 PowerShell)
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
& "\\wsl.localhost\Ubuntu-22.04\home\<wsl유저명>\forge\.claude\scripts\setup-windows-symlinks.ps1"
# → agents/commands/rules/skills/prompts/forge 심볼릭 자동 생성
```

이미 forge를 받은 팀원은 `git pull` 후 위 명령어만 실행하면 됨.

---

## 주의사항

- WSL UNC 경로(`\\wsl.localhost\...`)는 **junction point 미지원** → `mklink /D`(symlink) 사용
- PowerShell 스크립트에 한글/특수문자 포함 시 인코딩 오류 → **영문으로 작성**
- `mklink /D`는 PowerShell 직접 실행 불가 → `cmd /c "mklink /D ..."` 패턴 사용
