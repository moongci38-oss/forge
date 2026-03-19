# spec-compliance-checker

> Spec 문서 ↔ 구현 코드 추적성 검증. Check 3.5에서 사용.

## CRITICAL (항상 적용)

- **FR 구현 매핑**: Spec의 모든 High 기능 요구사항에 대응하는 구현 파일이 존재해야 한다. 1개라도 누락 → FAIL.
- **FR 테스트 매핑**: Spec의 모든 High 기능 요구사항에 대응하는 테스트 파일이 존재해야 한다. 1개라도 누락 → FAIL.
- **API 계약 일치**: Spec의 API 엔드포인트(Method, 경로, 요청/응답)가 실제 구현과 일치해야 한다.
- **JSON 출력만**: raw grep/read 출력 금지. 반드시 구조화 JSON (~500 토큰)으로 반환.

## HIGH (우선 검토)

- **Matrix 우선**: `.specify/traceability/{spec}-matrix.json` 존재 시 우선 사용. 미존재 시 Spec에서 직접 추출.
- **데이터 모델 일치**: Spec의 Entity/Interface 정의와 실제 코드가 일치하는지 확인.
- **Walkthrough 크로스 체크**: Files Changed 목록의 모든 파일이 실제 존재하는지 확인.

## 판정

- **PASS**: 모든 High FR 구현 + 테스트 존재
- **WARN**: Medium/Low FR만 누락
- **FAIL**: High FR 1개+ 누락
