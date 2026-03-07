---
description: 포트폴리오 프로젝트 전체 자동 분석 — 병렬 분석 → 이미지 추출 → 문서 생성 → 자체 검증
argument-hint: "[프로젝트 경로] (기본값: E:\portfolio_project)"
allowed-tools: Bash, Task, Read, Write, TaskOutput
---

# Portfolio Analyze — 자동화 파이프라인

포트폴리오 프로젝트들을 병렬로 분석하고 즉시 사용 가능한 포트폴리오 데이터를 생성한다.

## 기본 경로 설정
```
BASE_DIR = $ARGUMENTS 이 비어있으면 "E:\portfolio_project" 사용
OUTPUT_DIR = Z:\home\damools\business\05-design\portfolio
ANALYSIS_DIR = {OUTPUT_DIR}\_analysis
SCRIPTS_DIR = Z:\home\damools\business\09-tools\scripts
```

---

## Step 0: 프로젝트 자동 발견

아래 PowerShell 명령으로 분석 대상 프로젝트 목록을 동적으로 수집한다.
Bash 도구로 실행:

```powershell
powershell.exe -Command "
Get-ChildItem -Path '{BASE_DIR}' -Directory |
  Where-Object { \$_.Name -notmatch '^_' } |
  Select-Object -ExpandProperty Name
"
```

**project_id 변환 규칙** (폴더명 → kebab-case):
- 공백 → `-`
- 대문자 → 소문자
- `_` → `-`
- 특수문자 제거
- 예: `clayon source` → `clayon-source`, `NCLSource` → `ncl-source`, `SmartDoor` → `smart-door`

발견된 프로젝트 목록을 확인하고 `_portfolio-data` 같은 출력 폴더는 제외한다.

---

## Step 1: 출력 디렉토리 생성

Bash 도구로 실행:

```powershell
powershell.exe -Command "
\$base = '{OUTPUT_DIR}'
\$dirs = @('projects', '_analysis') + @({PROJECT_IDS} | ForEach-Object { \"images\\\$_\" })
\$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path \"\$base\\\$_\" | Out-Null }
Write-Host 'Directories ready.'
"
```

---

## Step 2: 병렬 실행 — 분석 + 이미지 추출 (동시)

**단 한 번의 메시지에서 모든 Tool Call을 동시에 실행한다.**

### 2a: portfolio-analyzer 병렬 실행

발견된 각 프로젝트에 대해 Task 도구로 portfolio-analyzer 에이전트를 **동시에** 호출한다.
(run_in_background 없이 하나의 메시지에서 여러 Task 호출 = 병렬 실행)

각 에이전트에 전달할 프롬프트:
```
다음 프로젝트를 분석하라:
- PROJECT_FOLDER: {폴더명}
- PROJECT_ID: {kebab-id}
- OUTPUT_PATH: {ANALYSIS_DIR}

분석 후 {ANALYSIS_DIR}\{project_id}.json 에 저장하라.
완료 시 "DONE: {project_id}.json saved" 한 줄만 출력.
```

### 2b: 이미지 추출 병렬 실행 (2a와 동시)

2a와 같은 메시지에서 Bash 도구로 이미지 추출 스크립트를 병렬 실행:

```powershell
powershell.exe -Command "
\$projects = @(
  @{folder='{FOLDER1}'; id='{ID1}'},
  @{folder='{FOLDER2}'; id='{ID2}'}
  # ... 발견된 프로젝트 전체
)
\$jobs = \$projects | ForEach-Object {
  \$f = \$_.folder; \$i = \$_.id
  Start-Job -ScriptBlock {
    param(\$folder, \$id, \$scripts, \$base)
    & powershell.exe -File \"\$scripts\extract-portfolio-images.ps1\" -ProjectFolder \$folder -ProjectId \$id -BaseDir \$base -OutputBase '{OUTPUT_DIR}'
  } -ArgumentList \$f, \$i, '{SCRIPTS_DIR}', '{BASE_DIR}'
}
\$results = \$jobs | Wait-Job | Receive-Job
\$jobs | Remove-Job
\$results | ForEach-Object { Write-Host \$_ }
"
```

---

## Step 3: 문서 생성 + 자체 검증

Step 2가 완전히 완료된 후 portfolio-content-writer 에이전트를 단 한 번 호출한다.

Task 도구로 portfolio-content-writer 호출:
```
{ANALYSIS_DIR} 폴더의 모든 JSON 파일을 읽어
가이드 스키마에 맞는 projects.json을 생성하라.

분석 JSON: {ANALYSIS_DIR}\*.json
이미지 JSON: {ANALYSIS_DIR}\*-images.json
출력: {OUTPUT_DIR}\projects.json (JSON 배열, 11개 항목)

각 항목 content 필드 작성 후 루브릭 검증 필수. 미달 섹션 즉시 재작성.
완료 시 "DONE: projects.json 생성 완료 — N개 항목 (검증 통과)" 한 줄만 출력.
```

---

## Step 4: 최종 검증 보고

모든 Task 완료 후 Bash로 결과를 확인하고 보고한다:

```powershell
powershell.exe -Command "
\$jsonPath = '{OUTPUT_DIR}\projects.json'
if (-not (Test-Path \$jsonPath)) {
  Write-Host 'ERROR: projects.json 없음'
  exit 1
}
\$projects = Get-Content \$jsonPath | ConvertFrom-Json
\$images   = Get-ChildItem '{OUTPUT_DIR}\images' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object
Write-Host '=== Portfolio Data 생성 완료 ==='
Write-Host \"projects.json: \$(\$projects.Count)개 항목\"
Write-Host \"이미지 파일: \$(\$images.Count)개\"
Write-Host ''
Write-Host '--- 프로젝트 목록 ---'
\$projects | ForEach-Object {
  \$featured = if (\$_.isFeatured) { '★' } else { ' ' }
  Write-Host \"\$featured [\$(\$_.category.PadRight(14))] #\$(\$_.orderIndex) \$(\$_.title) — \$(\$_.techStack -join ', ')\"
}
"
```

---

## 실행 원칙

1. **Step 2의 모든 Task/Bash 호출은 반드시 하나의 메시지에서 동시 실행** (순차 실행 금지)
2. **Step 3은 Step 2가 100% 완료된 후에만 실행**
3. **에이전트 반환값은 "DONE: ..." 한 줄** — 대용량 데이터를 메인 컨텍스트로 가져오지 않음
4. 오류 발생 시: 해당 프로젝트만 재시도 (전체 재실행 금지)
5. 기존 분석 파일이 있어도 덮어쓰기 (항상 최신 상태 유지)
