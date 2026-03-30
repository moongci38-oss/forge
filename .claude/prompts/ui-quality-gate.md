# Check 3.6: UI/UX 품질 게이트 (Subagent 전용)

> 이 Prompt는 Check 3.6 Subagent에만 주입. 메인 세션 Rules에 포함하지 않음.

## 트리거 조건

UI 관련 파일 (`.tsx`, `.jsx`, `.vue`, `.css`, `.scss`, `.svg`, `.png`, `.jpg`, `.webp`, `.avif`) 변경 시에만 실행.

## 검증 영역

### 1. 정적 UI 검증 (프로젝트별 스크립트)

프로젝트 검증 스크립트 실행 (예: `verify.sh ui`).

**공통 검사 항목:**

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| alt 속성 누락 | 이미지에 alt 없음 |
| 디자인 토큰 미사용 | 하드코딩 색상 직접 사용 |
| AI 슬롭 텍스트 | "delve", "leverage" 등 AI 생성 마커 |

### 2. 이미지 품질

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| 파일 크기 | 500KB 초과 |
| 포맷 | WebP/AVIF 미사용 (PNG/JPG만 존재) |
| 해상도 | OG 이미지 1200x630 미충족 |

### 3. 성능/접근성 감사 (MCP 가용 시)

| 도구 | 기준 |
|------|------|
| Lighthouse MCP | LCP < 2.5s, CLS < 0.1 |
| A11y MCP (axe-core) | critical/serious = FAIL |

### 4. 반응형 시각 검증 (Playwright MCP 가용 시)

| 뷰포트 | 사이즈 |
|--------|--------|
| Mobile | 375x812 |
| Tablet | 768x1024 |
| Desktop | 1440x900 |
| Dark Mode | Desktop + prefers-color-scheme: dark |

## 결과 반환 형식 (JSON)

```json
{
  "checkId": "check-3.6",
  "status": "PASS|WARN|FAIL",
  "staticUI": { "status": "PASS|FAIL", "issues": [] },
  "imageQuality": { "status": "PASS|FAIL", "issues": [] },
  "lighthouse": { "lcp": 0, "cls": 0, "a11yScore": 0 },
  "wcag": { "critical": 0, "serious": 0, "moderate": 0 },
  "responsive": { "mobile": "PASS|FAIL", "tablet": "PASS|FAIL", "desktop": "PASS|FAIL", "dark": "PASS|FAIL" },
  "summary": "",
  "autoFixable": false
}
```
