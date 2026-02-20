# 포트폴리오 파이프라인 상태 관리 시스템

> 작성일: 2026-02-19
> 상태: 계획 (미구현)

---

## 1. 배경 및 목적

포트폴리오 이미지 생성 파이프라인(`/portfolio-analyze`)은 4단계(발견→분석→이미지→콘텐츠)로 구성되어 있다.
현재 각 단계 완료 여부를 추적하는 상태 관리 시스템이 없어, 파이프라인 중단 시 어디서부터 재개해야 하는지 알 수 없다.

**목표**: 영구 스크립트 + YAML 상태 파일로 파이프라인 진행 상황을 자동 추적하는 시스템 구축

---

## 2. 아키텍처

### 구성 요소

| 구성 요소 | 경로 | 역할 |
|-----------|------|------|
| 상태 파일 | `05-design/portfolio/pipeline-state.yaml` | 프로젝트별 단계 상태 영속 저장 |
| 관리 스크립트 | `09-tools/scripts/update-pipeline-state.sh` | 상태 조회/변경 CLI 도구 |
| 슬래시 커맨드 | `.claude/commands/portfolio-analyze.md` | 파이프라인 실행 시 상태 자동 업데이트 |

### 데이터 흐름

```
/portfolio-analyze 실행
  │
  ├─ Step 0: --init → 프로젝트 발견, 상태 파일 초기화
  │
  ├─ Step 1: 분석 완료 → --task {id} --step analyze --status done
  │
  ├─ Step 2: 이미지 완료 → --task {id} --step images --status done
  │
  ├─ Step 3: 콘텐츠 완료 → --task {id} --step content --status done
  │
  └─ Step 4: 검증 통과 → --task {id} --step validate --status done
```

---

## 3. 상태 파일 스펙

### 파일: `05-design/portfolio/pipeline-state.yaml`

```yaml
pipeline:
  last_updated: "2026-02-19T10:30:00"
  version: "1.0"

projects:
  albanow:
    discover: done
    analyze: done
    images: done
    content: done
    validate: done
  mukja:
    discover: done
    analyze: done
    images: in_progress
    content: pending
    validate: pending
```

### 단계 정의 (5단계)

| 단계 | 설명 |
|------|------|
| `discover` | 프로젝트 폴더 감지 (`E:\portfolio_project` 스캔) |
| `analyze` | 코드베이스 분석 JSON 생성 (`portfolio-analyzer` 에이전트) |
| `images` | 이미지 추출/리사이즈 완료 (`portfolio-image-extractor` 에이전트) |
| `content` | projects.json 콘텐츠 작성 (`portfolio-content-writer` 에이전트) |
| `validate` | 최종 검증 통과 (JSON 스키마, 이미지 존재 확인) |

### 상태값

| 상태 | 의미 |
|------|------|
| `pending` | 아직 시작하지 않음 |
| `in_progress` | 현재 진행 중 |
| `done` | 완료 |
| `failed` | 실패 (재시도 필요) |

---

## 4. 관리 스크립트 스펙

### 파일: `09-tools/scripts/update-pipeline-state.sh`

### 사용법

```bash
# 상태 파일 초기화 (E:\portfolio_project 스캔 → 전체 프로젝트 pending)
bash 09-tools/scripts/update-pipeline-state.sh --init

# 특정 프로젝트의 특정 단계 상태 변경
bash 09-tools/scripts/update-pipeline-state.sh --task <project_id> --step <step> --status <status>

# 전체 현황 테이블 출력
bash 09-tools/scripts/update-pipeline-state.sh --list

# 특정 상태만 필터링
bash 09-tools/scripts/update-pipeline-state.sh --list --filter pending

# 요약 통계
bash 09-tools/scripts/update-pipeline-state.sh --summary
```

### 기능 상세

#### `--init`
- `E:\portfolio_project` 하위 디렉토리 스캔
- 각 프로젝트의 5단계를 모두 `pending`으로 초기화
- `pipeline.last_updated`에 현재 시각 기록
- 기존 상태 파일이 있으면 백업 후 덮어쓰기

#### `--task <id> --step <step> --status <status>`
- 지정 프로젝트의 지정 단계 상태를 변경
- `pipeline.last_updated` 자동 갱신
- 유효하지 않은 project_id, step, status 입력 시 에러 메시지 출력

#### `--list`
- 프로젝트별 5단계 상태를 테이블 형태로 출력

```
PROJECT        DISCOVER  ANALYZE  IMAGES   CONTENT  VALIDATE
albanow        done      done     done     done     done
mukja          done      done     progress pending  pending
crawling       done      pending  pending  pending  pending
...
```

#### `--list --filter <status>`
- 해당 상태를 하나라도 가진 프로젝트만 필터링

#### `--summary`
- 전체 통계 한 줄 요약

```
done: 45/55 (81.8%) | in_progress: 2 | pending: 5 | failed: 3
```

### 의존성

- **`yq`** (YAML 파싱 CLI 도구) — 우선 사용
- `yq` 미설치 시 `sed`/`awk` 기반 폴백 로직 포함

---

## 5. 파이프라인 통합 방법

`/portfolio-analyze` 슬래시 커맨드(`.claude/commands/portfolio-analyze.md`)에 각 단계 완료 시점에 상태 업데이트 호출을 추가한다.

### 통합 포인트

```
Step 0 (발견):
  bash 09-tools/scripts/update-pipeline-state.sh --init

Step 2a (분석 완료 시):
  bash 09-tools/scripts/update-pipeline-state.sh --task albanow --step analyze --status done

Step 2b (이미지 완료 시):
  bash 09-tools/scripts/update-pipeline-state.sh --task albanow --step images --status done

Step 3 (콘텐츠 완료 시):
  bash 09-tools/scripts/update-pipeline-state.sh --task albanow --step content --status done

Step 4 (검증 통과 시):
  bash 09-tools/scripts/update-pipeline-state.sh --task albanow --step validate --status done
```

### 실패 처리

- 각 단계에서 에러 발생 시 해당 단계를 `failed`로 기록
- `--list --filter failed`로 실패한 프로젝트만 확인 후 재실행 가능

---

## 6. 검증 방법

| # | 테스트 | 예상 결과 |
|---|--------|----------|
| 1 | `--init` 실행 | 11개 프로젝트 모두 5단계 `pending`으로 생성 |
| 2 | `--task albanow --step analyze --status done` | albanow.analyze 값이 `done`으로 변경 |
| 3 | `--list` 실행 | 프로젝트별 5열 테이블 정상 출력 |
| 4 | `--summary` 실행 | 정확한 상태별 카운트 및 퍼센트 출력 |
| 5 | `--list --filter failed` | failed 상태가 있는 프로젝트만 표시 |

---

## 7. 향후 확장

- **자동 재개**: `--resume` 플래그로 `in_progress`/`failed` 상태 프로젝트부터 파이프라인 자동 재실행
- **알림**: 파이프라인 완료/실패 시 Notion 또는 콘솔 알림
- **히스토리**: 상태 변경 이력을 별도 로그 파일에 기록
- **대시보드**: `--list` 출력을 HTML로 변환하여 시각적 진행 현황 제공
