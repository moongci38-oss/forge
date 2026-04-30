---
name: agents-suspicious-patterns
description: 코드 리뷰·검토 에이전트가 플래그해야 할 의심 코드 패턴 목록. detect-injection 훅 보완용.
type: reference
---

# AGENTS.md — 의심 코드 패턴

코드 리뷰, ultrareview, qa 스킬, Evaluator subagent가 이 파일을 참조해 의심 패턴을 검출한다.

## 카테고리 1: 코드 실행 위험 (High)

| 패턴 키워드 | 위험도 | 설명 |
|------------|:------:|------|
| `eval` 함수 호출 | High | 동적 코드 실행 — 인젝션 진입점 |
| `exec` 함수 호출 | High | 동적 코드 실행 — 셸 인젝션 위험 |
| `Function` 생성자 | High | 동적 함수 생성 — eval 우회 패턴 |
| subprocess shell=True | High | 셸 인젝션 직접 노출 |
| os.system | High | 셸 명령 직접 실행 |
| Node child_process | High | Node.js 셸 실행 — execFile 대신 사용 권장 |
| dangerouslySetInnerHTML | High | XSS 직접 주입 |

## 카테고리 2: 하드코딩 자격증명 (Critical)

| 패턴 키워드 | 위험도 | 설명 |
|------------|:------:|------|
| `password = "..."` 리터럴 | Critical | 평문 비밀번호 |
| `api_key = "..."` 리터럴 | Critical | API 키 하드코딩 |
| `secret = "..."` 리터럴 | Critical | 시크릿 하드코딩 |
| `token = "..."` 리터럴 | Critical | 토큰 하드코딩 |
| `sk-` 접두사 문자열 | Critical | OpenAI API 키 노출 |
| ANTHROPIC_API_KEY 리터럴 | Critical | Anthropic 키 노출 |
| AWS_ACCESS_KEY, AWS_SECRET 리터럴 | Critical | AWS 자격증명 |

## 카테고리 3: 보안 약화 패턴 (Medium)

| 패턴 키워드 | 위험도 | 설명 |
|------------|:------:|------|
| verify=False (requests) | Medium | TLS 검증 비활성화 |
| ssl_verify=False | Medium | SSL 검증 비활성화 |
| chmod 777 | Medium | 전체 권한 부여 |
| 0.0.0.0 바인딩 | Medium | 전체 인터페이스 노출 (의도 확인) |
| DEBUG=True in production | Medium | 프로덕션 디버그 모드 |
| allow_origins=["*"] CORS | Medium | 전체 오리진 허용 |

## 카테고리 4: 프롬프트 인젝션 위험 (에이전트 전용)

| 패턴 | 위험도 | 설명 |
|------|:------:|------|
| 외부 입력 → LLM prompt 직접 삽입 | High | f-string으로 사용자 입력 삽입 패턴 |
| 시스템 프롬프트에 사용자 데이터 병합 | High | 인젝션 진입점 |
| Telegram/Slack 메시지 → CLI 직접 전달 | High | agent-server 인젝션 경로 |

## 빠른 스캔 (bash)

```bash
# 코드 실행 패턴 스캔
grep -rn "os\.system\|shell=True\|dangerously" --include="*.py" --include="*.ts" .

# 자격증명 스캔
grep -rn "password\s*=\s*[\x27\x22]\|api_key\s*=\s*[\x27\x22]" --include="*.py" --include="*.js" .
```

## 판정 기준

- **Critical**: 즉시 차단. 커밋 전 수정 필수
- **High**: 경고 + 의도 확인 요청
- **Medium**: 주의 표시, 컨텍스트에 따라 허용 가능

## 허용 예외

- 테스트 파일 내 하드코딩 (실제 값이 아닌 경우)
- 환경변수 참조 (os.getenv 방식) — 하드코딩 아님
- 문서/주석 내 패턴 예시

---
*출처: Claude+Codex 듀얼 에이전트 워크플로우 분석 (2026-04-30)*
*관련 훅: ~/.claude/hooks/detect-injection.sh*
