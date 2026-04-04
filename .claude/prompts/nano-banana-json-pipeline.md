# nano-banana JSON 이미지 편집 파이프라인

> 이미지 편집 시 자연어 단일 호출 대신 JSON 3단계 파이프라인을 사용한다.
> 목적: 의도하지 않은 요소 변경(할루시네이션) 최소화, 색상 정밀 제어.

---

## 3단계 표준 패턴

### Step 1 — 이미지 분석 → JSON 출력

`mcp__nano-banana__edit_image`에 분석 프롬프트를 전달하여 이미지 구조를 JSON으로 출력받는다.

```
이 이미지를 분석하고 아래 JSON 구조로 출력해줘. 수정은 하지 말고 분석만:

{
  "background": { "color": "<hex>", "gradient": "<설명 또는 null>" },
  "elements": [
    {
      "id": "<요소명>",
      "type": "text|shape|icon|image",
      "content": "<텍스트 내용 또는 설명>",
      "color": "<hex>",
      "position": "<top-left|center|bottom-right 등>",
      "size": "<relative: small|medium|large>"
    }
  ],
  "style": {
    "mood": "<설명>",
    "primaryColor": "<hex>",
    "fontStyle": "<serif|sans-serif|handwritten 등>"
  }
}
```

### Step 2 — 수정할 필드 특정

Step 1 JSON에서 변경할 필드만 명시한다. 나머지는 건드리지 않는다.

```
아래 필드만 수정해줘:
- elements[id="<요소명>"].color: "<현재값>" → "<새 hex값>"
- background.color: "<현재값>" → "<새 hex값>"
```

**design-tokens 참조 시:**
`forge/shared/design-tokens/instagram-default.json`의 값을 사용한다.

| 용도 | hex |
|------|-----|
| 브랜드 Yellow | #FEDA75 |
| 브랜드 Orange | #FA7E1E |
| 브랜드 Pink | #D62976 |
| 브랜드 Purple | #962FBF |
| 브랜드 Blue | #4F5BD5 |
| 텍스트 Primary | #262626 |
| 배경 Primary | #FFFFFF |
| 링크 Blue | #0095F6 |

### Step 3 — 수정된 JSON + 원본 이미지로 재합성

```
원본 이미지에서 아래 JSON의 수정 사항만 적용해줘. 그 외 요소는 완전히 동일하게 유지:

<Step 2에서 확정한 수정 JSON>
```

---

## 적용 범위

| 작업 | 권장 여부 |
|------|---------|
| 색상 변경 (단일/다중 요소) | ✅ 필수 |
| 텍스트 내용 변경 | ✅ 권장 |
| 요소 추가/제거 | ✅ 권장 |
| 전체 스타일 변경 | 🟡 Step 1 생략 가능 |
| 단순 배경색 1회 변경 | 🟡 직접 호출도 무방 |

---

## 예시: GodBlade 에셋 색상 배리에이션

```
# Step 1
이 캐릭터 이미지를 분석하고 JSON으로 출력해줘 (수정 없이)

# Step 2
armor.color: "#C0C0C0" → "#D62976"  ← design-tokens brand.pink

# Step 3
원본 이미지에서 armor 색상만 #D62976으로 변경. 나머지 동일 유지.
```

---

*참조: `forge/shared/design-tokens/instagram-default.json`*
*Last Updated: 2026-04-02*
