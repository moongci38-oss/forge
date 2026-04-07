# 적용 계획서 — Claude HWPX 스킬 자동화
> 참조 영상: 클로드(claude)로 hwpx(한글) 한방에 채우기 | 이제 복잡한 보고서도 5분 컷!
> 원본 영상: https://youtu.be/tt50miJGquE
> 분석 파일: `01-research/videos/analyses/2026-04-07-tt50miJGquE-클로드-hwpx-한글-보고서-자동화-analysis.md`
> 작성일: 2026-04-07

---

## 핵심 배경

영상은 Claude.ai Web의 스킬 커넥터 UI를 통해 HWPX 파일을 생성하는 방식을 소개한다.
우리 환경(Claude Code CLI)은 다른 채널이지만, MCP 서버(`hwpx-mcp-server`)를 통해 동일한 결과를 더 정밀하게 달성할 수 있다.

현재 우리 시스템:
- `hwp2pdf` 스킬: HWP → PDF 변환 (읽기 전용)
- HWPX 생성(쓰기): **전무**
- 정부과제 제출 시 HWP 형식 요구 가능 → 현재 Word/PDF 우회 중

---

## 갭 분석

| 기능 | 영상 접근법 | 우리 현황 | 갭 |
|------|------------|---------|:--:|
| HWPX 생성 | Claude Web 스킬 커넥터 | 없음 | 쓰기 파이프라인 전무 |
| HWPX 편집/매핑 | 스킬 파일(.json) | 없음 | MCP 서버 미설치 |
| 정부과제 서식 자동 채우기 | 시연 미포함 | 수동 작성 | AI 자동화 없음 |

---

## P0 — 즉시 적용 (이번 주, 1시간 이내)

### [Forge MCP] hwpx-mcp-server 설치 검토

**현황**: HWPX 쓰기 기능 전무
**변경**: `uvx hwpx-mcp-server` 설치 후 Forge `.mcp.json`에 추가
**기대 효과**: Claude Code에서 직접 HWPX 파일 읽기·편집·생성 가능

**설치 방법:**
```bash
# 설치 테스트
uvx hwpx-mcp-server

# forge/.mcp.json에 추가
{
  "mcpServers": {
    "hwpx": {
      "command": "uvx",
      "args": ["hwpx-mcp-server"]
    }
  }
}
```

**검증 기준**: `uvx hwpx-mcp-server` 실행 후 MCP 연결 성공 여부

---

## P2 — 중기 (이번 달)

### [Forge/grants] HWPX 자동 채우기 워크플로우

**현황**: 정부과제 서류를 수동으로 HWP 형식에 입력
**변경**: `hwpx-mcp-server` 설치 후 grants 파이프라인에 HWPX 출력 단계 추가
  1. `/grants` 스킬로 내용 검토/작성 완료
  2. hwpx-mcp-server로 정부과제 서식 파일에 내용 자동 매핑
  3. 결과물 `forge-outputs/09-grants/` 저장
**기대 효과**: 정부과제 HWP 제출물 자동화 → 수동 복붙 시간 제거

---

## 제외 항목

| 항목 | 제외 이유 |
|------|---------|
| Claude.ai Web 스킬 커넥터 사용 | 우리 환경은 Claude Code CLI — Web UI 기반 접근법 적합하지 않음 |
| easy-hwp Claude Code 스킬(nathankim0) | hwpx-mcp-server가 더 강력하고 Code 환경에 적합 |
| 무료 요금제 활용 | 우리는 유료 요금제 사용 중, 해당 없음 |

---

## 실행 체크리스트

- [x] `pip install hwpx-mcp-server` 설치 완료 (2026-04-07, v2.2.5)
- [x] Forge `.mcp.json`에 hwpx 서버 등록 완료 (2026-04-07)
- [ ] 정부과제 기존 HWPX 서식 파일로 자동 채우기 시나리오 테스트 (담당: Business)
- [ ] gonggong_hwpxskills 공개 스킬 검토 (담당: Business)

---

## 참고 자료

| 자료 | URL |
|------|-----|
| hwpx-mcp-server | https://github.com/airmang/hwpx-mcp-server |
| easy-hwp 스킬 | https://github.com/nathankim0/easy-hwp |
| 공공문서 HWPX 스킬 | https://github.com/Canine89/gonggong_hwpxskills |
| hwpilot (MCP Market) | https://mcpmarket.com/tools/skills/hwp-hwpx-document-editor |
