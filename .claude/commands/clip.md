---
allowed-tools: Bash, Read
description: 클립보드 이미지를 캡처하여 현재 대화에 표시
---

Windows 클립보드에서 이미지를 가져와 표시합니다.

1. Bash로 아래 명령을 실행하여 클립보드 이미지를 저장:
```bash
powershell.exe -c "
\$img = Get-Clipboard -Format Image
if (\$img) { \$img.Save('$(wslpath -w /tmp/clip.png)'); Write-Host 'Saved' }
else { Write-Host 'No image in clipboard' }
" 2>/dev/null
```

2. 저장 성공 시 Read 도구로 `/tmp/clip.png` 파일을 읽어서 사용자에게 보여줍니다.
3. 저장 실패 시 "클립보드에 이미지가 없습니다"라고 안내합니다.
