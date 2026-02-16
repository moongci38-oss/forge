# GitHub Actions 종합 심층 분석 리포트 (2025-2026)

GitHub Actions는 2025년 8월 백엔드 아키텍처를 전면 재구축하여 **하루 7,100만 건의 Job을 처리**하는 세계 최대 CI/CD 플랫폼으로 자리잡았다. 엔터프라이즈 환경에서는 분당 7배 더 많은 Job을 시작할 수 있게 되었고, 2025년 한 해 동안 **115억 분의 Actions 실행 시간**을 기록했다. 이 리포트는 GitHub Actions의 아키텍처부터 AI 에이전트 통합, 엔터프라이즈 CI/CD, Self-hosted Runner, 보안, 비용 최적화까지 6개 핵심 영역을 실전 코드와 함께 심층 분석한다.

---

## 1. 아키텍처와 워크플로 문법 전체 구조

### 핵심 컴포넌트 계층 구조

GitHub Actions의 실행 단위는 **Event → Workflow → Job → Step → Action/Command**로 계층화된다. **Workflow**는 `.github/workflows/` 디렉토리에 YAML 파일로 정의되며, **Event**(push, PR, 스케줄 등)에 의해 트리거된다. **Job**은 동일한 Runner에서 실행되는 Step들의 집합으로 기본적으로 **병렬 실행**되며, `needs` 키워드로 의존성을 설정한다. 각 Job은 새로운 VM 인스턴스에서 실행되어 환경 격리를 보장한다. **Step**은 Job 내에서 순차 실행되며, `run:`(셸 명령)이나 `uses:`(재사용 가능 Action)으로 정의된다. **Runner**는 GitHub-hosted(Ubuntu, Windows, macOS), Larger Runner(2~96코어, GPU, ARM), Self-hosted의 세 유형이 존재한다.

주요 제한 사항으로는 Job당 최대 **6시간**, 워크플로 런당 최대 **35일**(대기/승인 시간 포함), 매트릭스 전략당 최대 **256개 Job**, 그리고 레포지토리당 캐시 크기 **10GB**가 있다. 동시 실행 Job 수는 플랜별로 Free 20개, Team 60개, Enterprise **500개**까지 지원된다.

### YAML 워크플로 문법 핵심 레퍼런스

워크플로 파일의 최상위 키는 `name`, `run-name`, `on`, `permissions`, `env`, `defaults`, `concurrency`, `jobs`로 구성된다. 아래는 모든 핵심 요소를 포함한 완전한 예시다:

```yaml
name: CI/CD Pipeline
run-name: "${{ github.workflow }} — ${{ github.ref_name }}"

on:
  push:
    branches: [main, 'release/**']
    paths-ignore: ['docs/**', '**.md']
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      deploy-env:
        type: choice
        options: [staging, production]
        default: staging
  schedule:
    - cron: '0 6 * * 1-5'

permissions:
  contents: read
  packages: write

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

defaults:
  run:
    shell: bash

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    strategy:
      fail-fast: false
      matrix:
        node: [18, 20, 22]
        include:
          - node: 22
            experimental: true
    continue-on-error: ${{ matrix.experimental || false }}
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      - uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ matrix.node }}-${{ hashFiles('package-lock.json') }}
          restore-keys: ${{ runner.os }}-node-${{ matrix.node }}-
      - run: npm ci && npm test
```

**`permissions`** 블록에서 사용 가능한 스코프는 `actions`, `checks`, `contents`, `deployments`, `id-token`, `issues`, `discussions`, `packages`, `pages`, `pull-requests`, `repository-projects`, `security-events`, `statuses`이며, 각각 `read`, `write`, `none` 값을 가진다. 하나라도 명시하면 명시되지 않은 나머지는 모두 `none`으로 설정되는 것이 중요한 보안 특성이다. **`concurrency`**는 워크플로 또는 Job 레벨에서 설정 가능하며, 동일 그룹 내에서는 최대 하나의 실행 + 하나의 대기만 허용된다.

### 트리거 이벤트 전체 종류

GitHub Actions는 **30개 이상의 웹훅 이벤트**와 5개의 특수 이벤트를 지원한다. 주요 이벤트를 분류하면:

- **코드 변경**: `push`, `pull_request`(opened/synchronize/reopened 등 20+ activity types), `pull_request_target`, `create`, `delete`
- **리뷰/코멘트**: `pull_request_review`, `pull_request_review_comment`, `issue_comment`, `discussion_comment`
- **이슈/프로젝트**: `issues`(opened/edited/closed 등 17 activity types), `label`, `milestone`
- **릴리스**: `release`(published/created/prereleased 등), `registry_package`
- **머지 큐**: `merge_group`(checks_requested) — merge queue 기능과 연동
- **특수 이벤트**: `schedule`(UTC 전용 cron, 2026년 타임존 지원 예정), `workflow_dispatch`(수동 트리거, string/boolean/choice/number/environment 입력 지원), `repository_dispatch`(외부 API 트리거), `workflow_call`(재사용 워크플로), `workflow_run`(다른 워크플로 완료 시 트리거, 최대 3레벨 체이닝)

### 매트릭스 전략 고급 활용

매트릭스는 `include`로 조합 추가/변수 확장, `exclude`로 특정 조합 제거가 가능하다. 처리 순서는 **exclude 먼저 → include 이후**이므로, exclude된 조합도 include로 재추가할 수 있다. 동적 매트릭스 패턴은 이전 Job에서 JSON을 출력하고 `fromJSON()`으로 파싱하는 방식이 실전에서 널리 사용된다:

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set.outputs.matrix }}
    steps:
      - id: set
        run: echo 'matrix={"node":[18,20],"os":["ubuntu-latest"]}' >> "$GITHUB_OUTPUT"
  test:
    needs: setup
    strategy:
      matrix: ${{ fromJSON(needs.setup.outputs.matrix) }}
    runs-on: ${{ matrix.os }}
```

### 재사용 가능 워크플로와 Action 유형 비교

**Reusable Workflow**는 `workflow_call` 트리거로 정의하며, `inputs`(string/number/boolean), `outputs`, `secrets`를 지원한다. `secrets: inherit`로 호출자의 모든 시크릿을 자동 전달할 수 있다. 2025년 업데이트로 **최대 4레벨 중첩**이 지원되며(기존 2레벨), Job 레벨에서만 호출 가능하다.

Action 유형별 핵심 차이는 다음과 같다. **JavaScript Actions**(`node20` 필수, node16 deprecated)는 가장 빠르고 크로스 플랫폼을 지원하지만 JS/TS만 사용 가능하다. **Docker Actions**는 완전한 환경 격리를 제공하나 Linux 전용이고 가장 느리다. **Composite Actions**는 YAML만으로 구성 가능하고 다른 Action을 `uses:`로 호출할 수 있어 가장 간편하지만, `runs-on:`을 지정할 수 없고 호출 Job의 Runner를 상속한다.

### Artifacts와 Caching 최신 변경사항

**actions/upload-artifact@v4**와 **actions/cache@v4**는 2025년 초 **완전히 새로운 백엔드**로 전환되었다. v3는 2025년 1월 30일부로 동작이 중단되었다. v4 아티팩트는 업로드/다운로드가 **최대 98% 빠르며**, 워크플로 런 내에서 각 아티팩트 이름이 **고유**해야 하는 것이 v3와의 주요 차이점이다. 캐시 v4(v4.2.0+)는 업로드가 **최대 80% 빠르고**, 캐시 항목은 **불변**(동일 키 덮어쓰기 불가)이다. 7일간 접근되지 않은 캐시는 자동 삭제되며, Runner 버전 **2.231.0+**이 필요하다.

### 2025-2026 주요 신기능

2025년 9월에 오랫동안 요청된 **YAML 앵커(`&`)와 별칭(`*`)**이 지원되었다(단, merge key `<<:`는 미지원). 2025년 8월에는 백엔드 전면 재설계가 완료되어 처리 능력이 3배 향상되었다. **2026년 1월 1일**부터 GitHub-hosted Runner 가격이 **최대 39% 인하**되었고, self-hosted Runner에 대한 $0.002/분 플랫폼 차지는 커뮤니티 반발로 **연기**되었다. 향후 예정된 기능으로는 스케줄 타임존 지원, Actions Data Stream(실시간 워크플로 이벤트 피드), ARC 0.14.0의 멀티 라벨 지원이 있다.

---

## 2. Claude Code Action과 AI 에이전트 통합

### anthropics/claude-code-action@v1 상세 분석

Anthropic의 공식 GitHub Action인 `anthropics/claude-code-action@v1`은 **4,200+ 스타, 1,300+ 포크**를 기록한 MIT 라이센스 프로젝트로, GitHub PR과 이슈에서 AI 에이전트로 동작한다. 핵심 특징은 **지능형 모드 감지**로, `prompt` 입력이 있으면 자동화 모드(즉시 실행), 없으면 인터랙티브 모드(`@claude` 멘션에 반응)로 작동한다.

주요 설정 옵션은 다음과 같다:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}  # 직접 API
    claude_code_oauth_token: ${{ secrets.TOKEN }}          # OAuth (Pro/Max)
    prompt: "이 PR을 리뷰해주세요"                         # 자동화 모드 활성화
    trigger_phrase: "@claude"                              # 커스텀 트리거
    assignee_trigger: "claude"                             # 어사인 트리거
    label_trigger: "claude"                                # 라벨 트리거
    track_progress: true                                   # 진행 추적 코멘트
    use_bedrock: 'true'                                    # AWS Bedrock 사용
    use_vertex: 'true'                                     # Google Vertex AI
    use_foundry: 'true'                                    # Microsoft Foundry
    additional_permissions: "actions: read"                 # CI/CD 도구 접근
    use_commit_signing: true                               # 커밋 서명
    plugins: "plugin1\nplugin2"                            # 플러그인 설치
    settings: '{"model": "claude-opus-4-1-20250805"}'      # 인라인 설정
    claude_args: |
      --max-turns 10
      --model claude-4-0-sonnet-20250805
      --system-prompt "코딩 표준을 따르세요"
      --allowedTools "Bash(npm install),Edit,Replace"
      --disallowedTools "WebFetch"
      --mcp-config '/tmp/mcp-config.json'
```

**`claude_args`**는 Claude CLI에 직접 전달되는 가장 강력한 커스터마이징 수단이다. `--max-turns`로 비용을 제어하고(리뷰용 5-10, 구현용 20+), `--model`로 모델을 선택하며, `--allowedTools`와 `--disallowedTools`로 도구 접근을 세밀하게 제한할 수 있다. **MCP 서버 설정**으로 외부 API, 시퀀셜 씽킹 서버 등을 통합할 수 있다.

### 실전 워크플로 패턴

**자동 PR 리뷰 + 인터랙티브 봇 통합 패턴** — 대부분의 팀이 채택하는 구성:

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request:
    types: [opened, synchronize, ready_for_review]
  issues:
    types: [opened, assigned, labeled]

jobs:
  claude:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: >-
            ${{ github.event_name == 'pull_request' &&
            'Review this PR for code quality, security, and performance' || '' }}
          claude_args: |
            --max-turns 10
            --system-prompt "TypeScript strict mode를 사용하세요. 모든 코드에 테스트가 필요합니다."
```

**이슈→PR 자동 구현 패턴** — `auto-implement` 라벨이 붙은 이슈를 자동으로 구현하고 PR을 생성한다. **CI 실패 자동 수정 패턴** — `workflow_run` 이벤트로 CI 실패를 감지하면 Claude가 로그를 분석하고 수정 커밋을 푸시한다. `additional_permissions: "actions: read"`를 설정하면 `mcp__github_ci__get_ci_status`, `mcp__github_ci__download_job_log` 도구가 활성화된다.

**AWS Bedrock 엔터프라이즈 설정**은 OIDC로 IAM Role을 Assume한 후 `use_bedrock: true`로 설정한다. `CLAUDE.md` 파일을 리포지토리 루트에 배치하면 프로젝트별 코딩 표준, 리뷰 기준, 컨텍스트 정보를 모든 상호작용에 자동 적용할 수 있다.

### 다른 AI GitHub Actions와의 비교

Claude Code Action과 GitHub Copilot Code Review의 핵심 차이는 **실행 능력**에 있다. Claude Code Action은 코드를 직접 수정하고 커밋을 푸시하며 PR을 생성할 수 있지만, Copilot Code Review는 코멘트와 제안만 가능하다. SWE-bench 점수는 Claude Opus 4.5가 **80.9%**, GPT-4.1이 **56.5%**로 상당한 차이를 보인다. Claude의 컨텍스트 윈도우는 최대 **100만 토큰**(Sonnet 4 beta)으로 Copilot의 64-128K보다 크다.

**CodeRabbit**은 46% 실제 버그 탐지율로 가장 인기 있는 AI 리뷰 봇이며, AST + SAST + AI 분석을 결합한다. **Qodo(CodiumAI)**는 멀티 리포 컨텍스트 엔진과 15+ 에이전틱 워크플로를 제공한다. Anthropic은 실험적으로 **TeammateTool**(에이전트 팀)을 개발 중이며, 팀 리더가 독립된 컨텍스트 윈도우에서 작업하는 팀원들을 조율하는 멀티 에이전트 패턴을 지원한다.

---

## 3. 엔터프라이즈 CI/CD 파이프라인 구축 패턴

### 모노레포 전략은 변경 감지가 핵심이다

모노레포 CI/CD의 가장 효과적인 접근법은 **dorny/paths-filter@v3**을 사용한 동적 경로 감지다. 네이티브 `paths` 필터는 워크플로 트리거 레벨에서만 동작하는 반면, paths-filter는 Job 레벨에서 조건부 실행을 가능하게 한다:

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.filter.outputs.frontend }}
      backend: ${{ steps.filter.outputs.backend }}
    steps:
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'shared/ui/**'
            backend:
              - 'backend/**'
              - 'shared/types/**'

  frontend-ci:
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: cd frontend && npm ci && npm run build
```

이 패턴으로 **CI 실행 시간과 비용을 60-80% 절감**할 수 있다. NX(`nx affected`)나 Turborepo도 빌드 그래프 기반 분석을 제공하지만, 순수 GitHub Actions 환경에서는 서비스별 독립 워크플로 + `paths` 스코핑이 가장 실용적이다.

### 멀티 환경 배포와 승인 게이트

GitHub Environments는 환경별 시크릿/변수 스코핑, **필수 리뷰어**(최대 6명), 대기 타이머(최대 30일), 배포 브랜치 제한, 커스텀 보호 규칙을 제공한다. `needs`를 통한 순차 체이닝으로 dev → staging → production 파이프라인을 구현한다:

```yaml
jobs:
  deploy-dev:
    environment: development
    runs-on: ubuntu-latest
    steps: [...]

  deploy-staging:
    needs: deploy-dev
    environment: staging
    steps: [...]

  deploy-production:
    needs: deploy-staging
    environment: production  # 수동 승인 필요
    steps: [...]
```

**커스텀 배포 보호 규칙**(GitHub Enterprise Cloud)은 GitHub Apps를 통해 Datadog, Honeycomb, New Relic 등 외부 서비스와 연동하여 옵저버빌리티 기반 승인을 자동화한다.

### Docker 빌드와 Kubernetes/ECS 배포 자동화

**엔터프라이즈급 Docker 빌드**의 핵심은 `docker/build-push-action@v6` + `docker/metadata-action@v5` + `docker/setup-buildx-action@v3` 조합이다. 캐싱 전략으로 `cache-from: type=gha` / `cache-to: type=gha,mode=max`(GitHub Actions 캐시 백엔드)를 사용하면 빌드 시간을 대폭 줄일 수 있다. `mode=max`는 최종 레이어뿐 아니라 모든 빌드 레이어를 캐시하므로 멀티스테이지 빌드에서 효과적이다.

**ECS 배포**는 `aws-actions/configure-aws-credentials@v4`(OIDC) → `aws-actions/amazon-ecr-login@v2` → 이미지 빌드/푸시 → `aws-actions/amazon-ecs-render-task-definition@v1` → `aws-actions/amazon-ecs-deploy-task-definition@v2`의 공식 Action 체인을 사용한다. **Kubernetes GitOps 패턴**에서는 CI(GitHub Actions)에서 이미지를 빌드하고 GitOps 리포의 `values.yaml`을 업데이트하면, CD(ArgoCD)가 자동으로 클러스터에 동기화한다. ArgoCD sync wave로 DB 마이그레이션 Job을 앱 Deployment보다 먼저 실행하는 것이 엔터프라이즈 Best Practice다.

### 릴리스 관리 자동화

**semantic-release**는 Conventional Commits를 분석하여 자동으로 버전을 결정하고 GitHub Release + CHANGELOG를 생성한다. **release-please**(Google)는 Release PR 기반 접근법으로, PR 머지 시 릴리스를 생성하여 더 많은 통제권을 제공한다. 두 도구 모두 `fetch-depth: 0`이 필수이며, 보호된 브랜치에서는 PAT가 필요하다(GITHUB_TOKEN은 보호 브랜치 푸시 불가).

---

## 4. Self-hosted Runner 아키텍처와 ARC

### 통신 모델과 아키텍처

Self-hosted Runner는 **아웃바운드 HTTPS만 사용**하며 인바운드 포트가 필요 없다. Runner 애플리케이션은 GitHub의 Broker API에 **50초 간격 HTTPS long-polling**으로 연결하여 Job을 수신한다. Job이 할당되면 **60초 이내에 픽업**해야 하며, 매칭되는 Runner가 없으면 최대 **24시간** 대기 후 실패한다. Runner는 repository, organization, enterprise 레벨에서 등록 가능하며, 30일 이내 자동 업데이트를 하지 않으면 Job 큐잉이 중단된다.

### Actions Runner Controller(ARC) 최신 버전

**gha-runner-scale-set 0.13.0**(2025년 10월 릴리스)이 최신 안정 버전이다. ARC는 Kubernetes CRD 기반으로 `AutoScalingRunnerSet` → `RunnerScaleSetListener`(GitHub long-poll) → `EphemeralRunnerSet` → `EphemeralRunner`의 리소스 계층을 사용한다.

설치는 두 단계로 진행된다:

```bash
# 1. 컨트롤러 설치
helm install arc \
  --namespace arc-systems --create-namespace \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

# 2. Runner Scale Set 설치
helm install arc-runner-set \
  --namespace arc-runners --create-namespace \
  --set githubConfigUrl="https://github.com/my-org" \
  --set githubConfigSecret.github_token="$GITHUB_PAT" \
  --set minRunners=1 --set maxRunners=20 \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

**0.10.0**(2025년 12월)에서 추가된 주요 기능은 **구성 가능한 rate limiter**(`k8sClientRateLimiterQPS`, `k8sClientRateLimiterBurst`), **Prometheus 메트릭**, `maxRunners: 0`으로 Job 수신과 Runner 생성을 동시 중지하는 유지보수 모드다. **멀티 라벨 지원은 ARC 0.14.0**(2026년 3월 예정)에서 추가될 예정이다.

2026년 2월 5일 퍼블릭 프리뷰로 공개된 **Runner Scale Set Client**(`actions/scaleset`)는 Kubernetes 없이 VM, 컨테이너, 베어메탈에서 커스텀 오토스케일링을 구현할 수 있는 Go 모듈이다. 인프라 프로비저닝은 사용자가 구현하고, GitHub API 오케스트레이션은 클라이언트가 처리한다.

### Ephemeral Runner와 보안 하드닝

`--ephemeral` 플래그로 구성된 Runner는 **정확히 하나의 Job만 실행**한 후 자동 등록 해제된다. ARC Runner는 기본적으로 ephemeral이다. JIT(Just-in-Time) 토큰을 사용하여 PAT/App 토큰이 Runner 파드에 전달되지 않는 것이 중요한 보안 특성이다.

보안 하드닝 핵심 체크리스트:

- **공개 리포지토리에서는 self-hosted Runner를 절대 사용하지 말 것** (포크가 악성 코드 실행 가능)
- Ephemeral 모드로 Job 간 상태 누출 방지
- 비특권 사용자 계정으로 실행, Runner와 프로덕션 워크로드 분리
- 네트워크 이그레스를 알려진 대상으로 제한, 프라이빗 서브넷 배치
- Action 참조를 **커밋 SHA로 고정**, `persist-credentials: false` 설정
- **StepSecurity Harden-Runner** 배포로 네트워크 이그레스/파일 무결성/프로세스 이상 탐지

2025년 실제 공격 사례가 이러한 하드닝의 필요성을 입증한다. **tj-actions/changed-files**(2025년 3월, CVE-2025-30066)는 훔친 PAT로 버전 태그를 재작성하여 23,000개 리포의 AWS 키와 토큰을 탈취했고, **Shai Hulud v2**(2025년 11월)는 2만+ 리포와 1,700개 npm 패키지를 감염시킨 자기 복제 웜이었다.

---

## 5. 보안 Best Practices 완전 가이드

### OIDC 기반 클라우드 인증이 표준이다

**OpenID Connect**는 GitHub OIDC 프로바이더가 각 워크플로 Job마다 JWT를 발급하고, 클라우드 프로바이더가 claims(repo, org, environment, branch 등)을 검증하여 **단기 액세스 토큰**을 발급하는 방식이다. 장기 자격 증명을 완전히 제거할 수 있어 2025-2026 Best Practice의 핵심이다.

**AWS 설정**: IAM에 OIDC Identity Provider 등록(`https://token.actions.githubusercontent.com`, 청중 `sts.amazonaws.com`) → Trust Policy에서 `sub` 클레임을 `repo:org/repo:environment:prod`로 정확히 매칭 → `aws-actions/configure-aws-credentials@v4`에서 `role-to-assume` 사용.

**GCP 설정**: Workload Identity Pool + Provider 생성 → `attribute-condition`으로 `assertion.sub` 제한 → 서비스 계정에 `workloadIdentityUser` 역할 부여 → `google-github-actions/auth@v2` 사용.

**Azure 설정**: Entra ID에 앱 등록 + 페더레이션 자격 증명(Issuer: `token.actions.githubusercontent.com`, Subject: `repo:org/repo:environment:production`) → `azure/login@v2` 사용.

세 클라우드 모두 공통적으로 `permissions: id-token: write`가 필수이며, Trust Policy에서 **와일드카드 대신 정확한 매칭**(`StringEquals`)을 사용해야 한다.

### 공급망 보안과 SLSA 준수

**Artifact Attestation**은 `actions/attest-build-provenance@v3`으로 Sigstore 기반 빌드 증명을 생성한다. 컨테이너 이미지에는 `push-to-registry: true`로 레지스트리에 직접 증명을 게시할 수 있다. SBOM은 `actions/attest-sbom@v2`로 별도 증명한다.

**SLSA Build L3** 달성을 위해서는 빌드를 **재사용 가능 워크플로로 분리**하여 서명 프로세스를 사용자 정의 Step과 격리해야 한다. 검증은 `gh attestation verify dist/my-binary --owner my-org`로 수행한다.

### 써드파티 Action 보안은 SHA 핀닝이 필수다

```yaml
# ✅ 안전: 전체 커밋 SHA 고정
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

# ⚠️ 위험: 변경 가능한 태그
- uses: actions/checkout@v4
```

`.github/dependabot.yml`에서 `package-ecosystem: "github-actions"`를 설정하면 Dependabot이 SHA 업데이트 PR을 자동 생성한다. 조직 설정에서 **레포지토리 룰셋으로 커밋 SHA 사용을 강제**할 수도 있다. **Zizmor**는 GitHub Actions 워크플로의 보안 미스컨피규레이션을 탐지하는 정적 분석 도구다.

### CodeQL과 Dependency Review 통합

```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v3
  with:
    languages: ${{ matrix.language }}
    queries: +security-extended

- name: Dependency Review
  uses: actions/dependency-review-action@v4
  with:
    fail-on-severity: moderate
    deny-licenses: GPL-3.0, AGPL-3.0
```

CodeQL은 JavaScript, Python, Ruby, Go, Java/Kotlin, C/C++, C#, Swift를 지원하며, `security-events: write` 권한이 필요하다. **GitHub Advanced Security**는 2025년 4월부터 **Secret Protection**과 **Code Security**로 분리되었고, Secret Scanning Push Protection으로 커밋 전 시크릿 유출을 차단한다.

---

## 6. 비용 최적화 전략과 과금 구조

### 플랜별 포함 시간과 분당 과금

GitHub Free는 월 **2,000분**, Team은 **3,000분**, Enterprise Cloud는 **50,000분**이 포함된다. 초과 시 분당 과금은 Linux 2코어 **$0.006**, Windows **$0.010**, macOS **$0.062**이다. macOS는 Linux 대비 **약 10배** 비싸다. **ARM64 러너는 x64 대비 17-40% 저렴**하여, ARM 호환 워크로드에서는 비용 절감 효과가 크다. 공개 리포지토리의 표준 러너는 무료이지만, Larger Runner는 공개 리포에서도 과금된다.

### Larger Runner와 GPU Runner 상세 과금

Linux Larger Runner는 4코어 $0.012/분부터 96코어 $0.252/분까지, Windows는 4코어 $0.022/분부터 96코어 $0.552/분까지 제공된다. **GPU Runner**(NVIDIA T4, 16GB VRAM)는 Linux $0.052/분, Windows $0.102/분으로 ML 모델 테스트, AI 추론 검증에 활용된다. GPU 워크로드는 매 PR이 아닌 **야간 스케줄이나 수동 라벨 트리거**로 실행하여 비용을 통제하는 것이 핵심이다.

### 캐싱으로 빌드 시간 50-85% 절감

의존성 캐싱의 효과는 상당하다. Go 빌드는 1분 20초에서 **18초**로(85% 감소), Node.js npm install은 45초에서 **5-10초**로 단축된다. Docker 레이어 캐싱은 `cache-from: type=gha` + `cache-to: type=gha,mode=max`가 가장 간편하며, 레지스트리 캐시(`type=registry`)는 팀 간 공유에 적합하다. 캐시 저장소는 레포당 기본 **10GB**이며, 추가 비용은 **$0.07/GiB/월**이다.

### Concurrency와 조건부 실행으로 비용 절감

**Concurrency + cancel-in-progress**의 비용 절감 효과는 극적이다. 15분짜리 CI 파이프라인에 5번 연속 푸시하면 일반적으로 75분이 소요되지만, concurrency 설정으로 마지막 실행만 완료하면 **15-20분으로 70-80% 절감**된다:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref && github.ref || github.run_id }}
  cancel-in-progress: true
```

**Job 타임아웃 설정**은 필수다. 기본값 6시간은 멈춘 Job이 Linux 2코어에서 $2.16을 소비하지만, `timeout-minutes: 20`으로 설정하면 $0.12로 제한된다. **아티팩트 보존 기간**을 90일(기본)에서 7일로 줄이면 저장소 사용량이 **92% 감소**한다.

**전략별 예상 절감률 요약**: Concurrency 설정 30-70%, 경로 필터 20-50%, 의존성 캐싱 40-80%(시간), 아티팩트 보존 단축 92%(스토리지), Linux 대신 macOS 회피 시 최대 90%, ARM 전환 17-40%, Job 체이닝 15-40%, Merge Queue 사용 30-60%.

---

## 결론: 핵심 인사이트와 전략적 권고

GitHub Actions는 2025-2026년에 **성능 3배 향상, 가격 최대 39% 인하, YAML 앵커 지원, 아티팩트/캐시 백엔드 전면 재구축**이라는 대대적인 진화를 거쳤다. 이 변화들이 수렴하는 방향은 명확하다: 엔터프라이즈 CI/CD의 **사실상 표준 플랫폼**으로의 확립이다.

**AI 에이전트 통합은 CI/CD의 패러다임을 전환하고 있다.** Claude Code Action은 단순한 코드 리뷰를 넘어 이슈 자동 구현, CI 실패 자동 수정, 멀티 에이전트 파이프라인까지 가능하게 한다. `CLAUDE.md`를 통한 프로젝트별 규칙 정의와 MCP 서버 통합이 결합되면, 인간 개발자와 AI 에이전트가 동일한 워크플로에서 협업하는 새로운 개발 패턴이 형성된다.

**보안은 반드시 선제적이어야 한다.** 2025년의 tj-actions와 Shai Hulud 공격은 SHA 핀닝, ephemeral Runner, OIDC, 최소 권한 원칙이 선택이 아닌 필수임을 증명했다. 특히 `permissions: {}`를 워크플로 최상위에 설정하고 Job별로 최소 권한만 부여하는 패턴, 모든 Action 참조의 커밋 SHA 고정, 그리고 OIDC 기반 클라우드 인증의 세 가지는 즉시 도입해야 할 보안 기본선이다.

**비용 최적화의 핵심은 "실행하지 않는 것"이다.** 경로 필터로 불필요한 워크플로를 건너뛰고, concurrency로 중복 실행을 취소하며, 캐싱으로 반복 작업을 제거하는 3단 전략이 가장 효과적이다. Self-hosted Runner는 월 50,000분 이상의 고볼륨 환경에서 비용 효율적이지만, 인프라 관리 비용과 2026년 예정된 플랫폼 차지를 반드시 고려해야 한다.