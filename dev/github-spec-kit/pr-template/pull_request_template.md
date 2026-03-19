<!-- =============================================================================
  PR 템플릿 — SDD 기반 Pull Request 체크리스트
  PR Template — SDD-based Pull Request Checklist

  [한글]
  기능: PR 생성 시 자동으로 채워지는 본문 템플릿.
        Spec/Plan 연결, 구현 내용, Spec 준수 체크리스트, 테스트,
        문서 업데이트, 리뷰어 체크리스트를 포함.
  사용 시점: GitHub에서 PR을 생성할 때 자동으로 이 템플릿이 본문에 삽입됨.
             (수동 선택 불필요 — .github/ 경로에 있으면 자동 적용)

  Trine 파이프라인 연계:
    - Phase 4 (PR 생성) 에서 AI가 이 템플릿을 기반으로 PR 본문 작성
    - "Spec Compliance Checklist" = Check 3.5 트레이서빌리티 검증 결과 반영
    - "Testing" = Check 3 (test/lint/build) 결과 반영
    - "For Reviewers" = Human 리뷰어가 최종 확인하는 체크리스트
    - spec-check.yml 워크플로우가 이 PR에 추가 검증 코멘트를 자동 작성

  배포 위치: 프로젝트의 .github/pull_request_template.md 에 복사하여 사용
             (주의: pr-template/ 폴더가 아닌 .github/ 루트에 직접 배치)

  [English]
  Purpose: Auto-populated PR body template when creating pull requests.
           Includes Spec/Plan links, changes, Spec compliance checklist,
           testing, documentation updates, and reviewer checklist.
  When used: Automatically inserted as PR body when creating a PR on GitHub.
             (No manual selection needed — auto-applied when placed in .github/)

  Trine pipeline integration:
    - In Phase 4 (PR creation), AI fills this template as PR body
    - "Spec Compliance Checklist" reflects Check 3.5 traceability results
    - "Testing" reflects Check 3 (test/lint/build) results
    - "For Reviewers" is the final checklist for Human reviewers
    - spec-check.yml workflow auto-posts additional validation comments on this PR

  Deployment: Copy to .github/pull_request_template.md in your project
              (Note: Place directly in .github/ root, not in a pr-template/ subfolder)
============================================================================= -->

## Related Spec & Plan

<!-- Link the related Spec and Plan documents -->
<!-- 관련 Spec 및 Plan 문서를 연결하세요 -->
- **Spec**: `.specify/specs/[spec-name].md`
- **Plan**: `.specify/plans/[plan-name]-plan.md`

## Description

<!-- Briefly describe the purpose and changes of this PR -->
<!-- 이 PR의 목적과 변경 내용을 간략히 설명하세요 -->

## Changes

<!-- List the key changes -->
<!-- 주요 변경 사항을 나열하세요 -->
-
-
-

## Spec Compliance Checklist

<!-- [한글] Spec 요구사항이 모두 충족되었는지 검증 -->
<!-- [English] Verify that all Spec requirements are met -->
- [ ] All features specified in the Spec are implemented
- [ ] API interfaces match the Spec
- [ ] Error handling follows the Spec
- [ ] Security requirements from the Spec are met
- [ ] Plan document updated (if needed)

## Testing

<!-- [한글] 테스트 체크리스트 — Check 3 결과 기반 -->
<!-- [English] Testing checklist — based on Check 3 results -->
- [ ] Unit tests written
- [ ] Integration tests written
- [ ] Spec scenario tests completed
- [ ] All tests pass locally

## Screenshots

<!-- Attach screenshots if there are UI changes -->
<!-- UI 변경이 있으면 스크린샷을 첨부하세요 -->

## Documentation

<!-- [한글] 문서 업데이트 체크리스트 -->
<!-- [English] Documentation update checklist -->
- [ ] README updated (if needed)
- [ ] API docs updated (if needed)
- [ ] Spec document updated (if there are changes)
- [ ] Inline comments and documentation written

## Related Issues

<!-- Link related Issues if any -->
<!-- 관련 이슈가 있으면 연결하세요 -->
- Closes #
- Related to #

## Additional Notes

<!-- Any additional information for reviewers -->
<!-- 리뷰어를 위한 추가 정보 -->

---

### For Reviewers

<!-- [한글] 리뷰어 체크리스트 — Human Gate (Phase 4 최종 검증) -->
<!-- [English] Reviewer checklist — Human Gate (Phase 4 final verification) -->
- [ ] Code meets Spec requirements?
- [ ] Test coverage sufficient?
- [ ] Coding conventions followed?
- [ ] No security vulnerabilities?
- [ ] No performance issues?

---

<!-- AI commits: Co-Authored-By: Claude <Model> <Version> <noreply@anthropic.com> -->
