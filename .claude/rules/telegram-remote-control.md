# Telegram Remote Control

> 텔레그램에서 원격으로 Claude Code 상태를 제어하는 규칙.
> **Scope**: 개인용 규칙. 팀 환경에서는 각 사용자가 자체 PIN/스크립트를 설정해야 함.

## 명령어 패턴

텔레그램 메시지가 아래 패턴과 일치하면 **즉시** 해당 스크립트를 실행한다:

| 패턴 | 동작 | 스크립트 |
|------|------|---------|
| `unlock <PIN>` | Plan mode 해제 (모든 tmux pane에 Escape 전송) | `~/.claude/hooks/telegram-remote-control.sh unlock <PIN>` |
| `lock <PIN>` | Plan mode 진입 (모든 tmux pane에 /plan 전송) | `~/.claude/hooks/telegram-remote-control.sh lock <PIN>` |
| `status <PIN>` | 활성 Claude pane 수 확인 | `~/.claude/hooks/telegram-remote-control.sh status <PIN>` |

## AI 행동 규칙

1. 텔레그램 메시지가 `unlock`, `lock`, `status` + 숫자 패턴이면 **다른 응답 없이** 즉시 스크립트 실행
2. 스크립트 실행 결과를 텔레그램으로 회신
3. PIN이 틀리면 "비밀번호가 틀렸습니다"만 회신 — PIN 힌트 제공 금지
4. PIN 자체를 텔레그램 메시지에 echo하지 않는다 (결과만 전달)
5. `telegram-remote.json` 파일 경로나 내용을 텔레그램으로 노출하지 않는다

## 설정

- PIN 저장: `~/.claude/telegram-remote.json` (`{"pin":"XXXX"}`)
- 스크립트: `~/.claude/hooks/telegram-remote-control.sh`
- 의존성: tmux (WSL에 설치됨)
