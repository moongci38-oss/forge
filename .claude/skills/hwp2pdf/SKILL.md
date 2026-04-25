---
name: hwp2pdf
description: HWP 파일을 PDF로 변환하여 이미지/도형/표 포함 100% 읽기 가능하게 만드는 스킬. HWP 파일 분석, 한글 문서 변환, 정부과제 서류 읽기 시 자동 트리거.
model: haiku
context: fork
---

> **응답 간결성 (Haiku 토큰 최적화)**: 구조화된 번호 목록 + 핵심 사실 위주로 답하세요. 장황한 설명·반복·메타 코멘트 금지. 각 항목 2문장 이내, 전체 300토큰 이하 목표.

**역할**: 당신은 HWP 파일을 PDF로 변환하여 이미지·도형·표 포함 완전 판독 가능하게 만드는 HWP 문서 변환 전문가입니다.
**컨텍스트**: HWP 파일 분석, 한글 문서 변환, 정부과제 서류 읽기 시 자동 트리거됩니다.
**출력**: 원본 HWP와 동일 경로에 PDF 파일을 생성하고 변환 결과를 반환합니다.

# HWP → PDF 변환 스킬

HWP 파일을 PDF로 변환하여 텍스트+이미지+도형+표를 완전히 읽을 수 있게 한다.

## 트리거 조건

- 사용자가 `.hwp` 파일 읽기/분석을 요청할 때
- 정부과제 서류(HWP) 내용을 확인해야 할 때
- `_source/` 폴더의 HWP 문서를 참조해야 할 때

## 변환 파이프라인

```
HWP → hwp5html(HTML+이미지) → Playwright(PDF)
```

## 사용법

### 단일 파일
```bash
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/hwp2pdf.py "파일.hwp"
```

### 폴더 일괄
```bash
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/hwp2pdf.py "폴더/"
```

### 출력 폴더 지정
```bash
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/hwp2pdf.py "파일.hwp" -o "/출력/경로/"
```

## 출력 구조

```
_converted/
├── 파일명.pdf          ← PDF (이미지/도형/표 포함)
```

기본 출력: 원본 폴더의 `_converted/` 하위.

## AI 행동 규칙

1. HWP 파일을 직접 Read하지 않는다 (바이너리 → 깨짐)
2. 먼저 `_converted/` 에 PDF가 이미 있는지 확인한다
3. 없으면 hwp2pdf.py를 실행하여 변환한다
4. 변환된 PDF를 Read 도구로 읽는다 (pages 파라미터 사용)
5. 텍스트만 필요한 경우 `_converted/` 의 `.txt` 파일을 사용한다 (hwp-convert.py로 생성)

## 관련 도구

| 도구 | 경로 | 용도 |
|------|------|------|
| **hwp2pdf.py** | `forge/shared/scripts/hwp2pdf.py` | HWP → PDF (이미지 포함) |
| **hwp-convert.py** | `forge/shared/scripts/hwp-convert.py` | HWP → TXT + HTML (텍스트+이미지 분리) |

## 품질

| 요소 | PDF 품질 |
|------|:-------:|
| 본문 텍스트 | ✅ 100% |
| 이미지/도형 | ✅ 100% |
| 표 구조 | ⚠️ ~90% (복잡한 병합 셀 일부 깨질 수 있음) |
| 서식(폰트/색상) | ⚠️ ~85% |

> 100% 완벽한 변환이 필요한 경우: Windows 한컴오피스에서 직접 PDF 내보내기 요청
