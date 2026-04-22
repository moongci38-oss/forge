---
allowed-tools: Bash, Read
description: 클립보드 이미지 또는 파일 경로 이미지를 현재 대화에 표시 (다중 지원)
---

Windows 클립보드 또는 지정 파일 경로에서 이미지를 가져와 표시합니다.

**사용법:**
- `/clip` — 클립보드 이미지 1개 캡처
- `/clip <경로1> [경로2] ...` — Windows 경로(또는 WSL 경로) 이미지 다중 로드

인자: `$ARGUMENTS`

## 처리 로직

인자(`$ARGUMENTS`)가 **비어있으면** 클립보드에서 캡처:

```bash
powershell.exe -c "
\$img = Get-Clipboard -Format Image
if (\$img) { \$img.Save('$(wslpath -w /tmp/clip_0.png)'); Write-Host 'Saved' }
else { Write-Host 'No image in clipboard' }
" 2>/dev/null
```

- 저장 성공 시 `/tmp/clip_0.png`를 Read로 읽어 표시
- 실패 시 "클립보드에 이미지가 없습니다" 안내

인자가 **있으면** 공백 구분으로 각 경로를 처리:
- Windows 경로(`C:\...`)는 `wslpath`로 WSL 경로로 변환
- 이미 `/`로 시작하는 WSL 경로는 그대로 사용
- 각 이미지를 번호와 함께 순서대로 Read로 읽어 표시
- 마지막에 "총 N개 이미지 표시됨" 안내

예시:
- `/clip C:\Users\user\Desktop\a.png C:\Users\user\Desktop\b.png`
- `/clip /tmp/screen1.png /tmp/screen2.png`
