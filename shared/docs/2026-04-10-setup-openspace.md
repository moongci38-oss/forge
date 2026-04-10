# OpenSpace 설치 가이드

> HKUDS의 스킬 자동 진화 프레임워크
> `/delegate-task`, `/skill-discovery` 스킬 활성화
> 소요 시간: ~10분

---

## OpenSpace란?

백그라운드에서 동작하는 스킬 품질 자동 개선 프레임워크.
`/grants-write`, `/yt`, `/pge` 등 실행 시 데이터를 자동 축적하고, 스킬을 점진적으로 진화시킨다.

**활성화되는 스킬:**
- `delegate-task` — 복잡한 작업을 전문 에이전트에 자동 위임
- `skill-discovery` — 스킬 품질 자동 모니터링 및 개선 제안

---

## 사전 요구사항

- `curl` 설치됨
- `git` 설치됨
- `~/forge/.env`에 `ANTHROPIC_API_KEY` 설정 완료

---

## 설치

### 1. uv 설치 (Python 패키지 관리자)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh

# 설치 후 PATH 적용
source ~/.bashrc   # 또는 source ~/.zshrc
```

### 2. Python 3.12 설치

```bash
uv python install 3.12
```

### 3. OpenSpace 클론 + 설치

```bash
cd ~
git clone https://github.com/HKUDS/OpenSpace.git
cd OpenSpace

# 가상환경 생성
uv venv --python 3.12 .venv
source .venv/bin/activate

# 의존성 설치 (순서 중요)
uv pip install pydantic-settings==2.13.0
uv pip install -e .
```

### 4. 설치 확인

```bash
source ~/OpenSpace/.venv/bin/activate
python -c "import openspace; print('OK')"
openspace-mcp --help
```

`OpenSpace MCP Server` 도움말이 출력되면 성공.

### 5. API 키 설정

```bash
# 방법 A: 직접 생성
echo "ANTHROPIC_API_KEY=본인_키_입력" > ~/OpenSpace/openspace/.env

# 방법 B: forge .env에서 복사
grep ANTHROPIC_API_KEY ~/forge/.env > ~/OpenSpace/openspace/.env
```

### 6. Forge MCP 연결

`~/forge/.mcp.json`에 아래 항목 추가 (`<유저명>`을 실제 계정명으로 교체):

```json
{
  "mcpServers": {
    "openspace": {
      "command": "/home/<유저명>/OpenSpace/.venv/bin/openspace-mcp",
      "toolTimeout": 600,
      "env": {
        "OPENSPACE_HOST_SKILL_DIRS": "/home/<유저명>/forge/.claude/skills",
        "OPENSPACE_WORKSPACE": "/home/<유저명>/OpenSpace"
      }
    }
  }
}
```

현재 유저명 확인:
```bash
echo $USER
```

### 7. 호스트 스킬 복사

```bash
cp -r ~/OpenSpace/openspace/host_skills/delegate-task/ ~/forge/.claude/skills/
cp -r ~/OpenSpace/openspace/host_skills/skill-discovery/ ~/forge/.claude/skills/
```

### 8. Claude Code 재시작

```
/clear
```

재시작 후 스킬 목록에 `delegate-task`, `skill-discovery`가 표시되면 완료.

---

## 사용법

평소처럼 Claude Code를 사용하면 됩니다. OpenSpace는 백그라운드에서 자동 동작.

수동으로 특정 스킬 개선을 요청할 때:
```
/skill-discovery
/delegate-task <복잡한 작업 설명>
```

---

## 업데이트

```bash
cd ~/OpenSpace
git pull
source .venv/bin/activate
uv pip install -e .
```

---

## 트러블슈팅

| 문제 | 해결 |
|------|------|
| `uv: command not found` | `source ~/.bashrc` 또는 터미널 재시작 |
| `Python 3.12 not found` | `uv python install 3.12` 재실행 |
| `pydantic_settings 설치 실패` | `uv pip install pydantic-settings==2.13.0` 먼저 실행 후 `uv pip install -e .` |
| OpenSpace MCP 연결 안 됨 | `/clear` 후 재시작. `.mcp.json`의 `<유저명>` 경로 확인 |
| `openspace-mcp: command not found` | `source ~/OpenSpace/.venv/bin/activate` 실행 후 `which openspace-mcp` 확인 |
| `delegate-task` 스킬 없음 | Step 7 호스트 스킬 복사 완료 여부 확인 |
| `ANTHROPIC_API_KEY` 오류 | `~/OpenSpace/openspace/.env` 파일 내용 확인 |
