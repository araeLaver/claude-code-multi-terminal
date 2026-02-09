# Claude Code Multi-Terminal Role Division Strategy

Claude Code 멀티 터미널 역할 분담 전략의 **템플릿/보일러플레이트** 저장소입니다.

이 구조를 복제하여 어떤 프로젝트든 역할이 분리된 멀티 터미널 워크플로우로 시작할 수 있습니다.

---

## 목차

- [왜 멀티 터미널인가?](#왜-멀티-터미널인가)
- [4-Terminal 체제](#4-terminal-체제)
- [Quick Start](#quick-start)
- [디렉토리 구조](#디렉토리-구조)
- [핵심 파일 상세 설명](#핵심-파일-상세-설명)
- [역할별 상세 규칙](#역할별-상세-규칙)
- [협업 흐름도](#협업-흐름도)
- [파일 기반 통신 체계](#파일-기반-통신-체계)
- [Task 생명주기](#task-생명주기)
- [유틸리티 스크립트](#유틸리티-스크립트)
- [Git 브랜치 전략](#git-브랜치-전략)
- [컨텍스트 리셋 전략](#컨텍스트-리셋-전략)
- [실전 운영 시나리오](#실전-운영-시나리오)
- [체크리스트: 매 세션 시작 시](#체크리스트-매-세션-시작-시)
- [커스터마이징 가이드](#커스터마이징-가이드)
- [FAQ](#faq)

---

## 왜 멀티 터미널인가?

### 단일 터미널의 문제

하나의 Claude Code 인스턴스에서 설계 + 구현 + 리뷰 + 인프라를 모두 처리하면:

| 문제 | 설명 |
|------|------|
| **컨텍스트 윈도우 소진** | 긴 대화로 초기 지시를 잊고, 코드 품질이 점진적으로 저하됨 |
| **역할 혼재** | "자기 코드를 자기가 리뷰"하는 편향이 생겨 버그를 놓침 |
| **역할 경계 붕괴** | 구현하다가 설계를 바꾸고, 테스트도 같이 쓰면서 독립성이 무너짐 |
| **병렬 작업 불가** | 하나의 터미널에서 순차적으로만 작업 가능 |

### 멀티 터미널의 해결

```
단일 터미널                              멀티 터미널
┌──────────────────┐                    ┌─────────┐ ┌─────────┐
│ 설계 + 구현 +     │         →         │ T1 설계  │ │ T2 구현  │
│ 리뷰 + 인프라     │                    └─────────┘ └─────────┘
│ (모두 뒤섞임)     │                    ┌─────────┐ ┌─────────┐
└──────────────────┘                    │ T3 리뷰  │ │ T4 인프라│
                                        └─────────┘ └─────────┘
컨텍스트 오염 O                          컨텍스트 오염 X
역할 편향 O                              역할 독립성 O
병렬 작업 X                              병렬 작업 O
```

**핵심 원칙**: 각 터미널이 자신의 도메인에만 집중하면서, **파일 시스템**을 통해 비동기적으로 협업합니다.

---

## 4-Terminal 체제

| Terminal | 역할 | 비유 | 핵심 책임 | 커밋 prefix |
|----------|------|------|----------|-------------|
| T1 | **Architect** | 두뇌 | 설계, Task Spec 작성, 오케스트레이션 | `[arch]` |
| T2 | **Implementor** | 손 | 핵심 비즈니스 로직 구현 | `[impl]` |
| T3 | **Reviewer** | 눈 | 코드 리뷰, 테스트 작성, QA | `[review]` |
| T4 | **DevOps** | 다리 | 인프라, CI/CD, 빌드/배포 | `[infra]` |

> 프로젝트 규모가 클 경우 **Terminal 5 (Documentation / Refactor)** 를 추가할 수 있습니다.

---

## Quick Start

### 1단계: 저장소 복제 & 초기화

```bash
git clone <this-repo> my-project
cd my-project
./scripts/init-project.sh
```

### 2단계: 프로젝트에 맞게 3개 파일 수정

```bash
vi CLAUDE.md              # 프로젝트 규칙, 기술 스택, 컨벤션
vi docs/architecture.md   # 시스템 설계, 모듈 정의, 데이터 모델
vi docs/tech-stack.md     # 기술 스택 상세 명세
```

### 3단계: 터미널 4개 열기

```bash
# tmux 사용 시 4분할
tmux new-session -s project
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0 && tmux split-window -v

# 패널 이름 지정 (선택)
tmux select-pane -t 0 -T "T1-Architect"
tmux select-pane -t 1 -T "T2-Implementor"
tmux select-pane -t 2 -T "T3-Reviewer"
tmux select-pane -t 3 -T "T4-DevOps"
```

### 4단계: 각 터미널에서 역할 진입

```bash
# Terminal 1 - Architect
claude
/project:architect

# Terminal 2 - Implementor
claude
/project:implementor

# Terminal 3 - Reviewer
claude
/project:reviewer

# Terminal 4 - DevOps
claude
/project:devops
```

### 5단계: 모니터 실행 (별도 터미널 또는 tmux 패널)

```bash
./scripts/monitor.sh
```

---

## 디렉토리 구조

```
project-root/
│
│  ═══════════════════════════════════════
│  프로젝트 규칙 (모든 터미널이 자동 로드)
│  ═══════════════════════════════════════
├── CLAUDE.md                          # 프로젝트 헌법
├── README.md                          # 이 문서
├── .gitignore
│
│  ═══════════════════════════════════════
│  역할별 슬래시 커맨드
│  ═══════════════════════════════════════
├── .claude/
│   └── commands/
│       ├── architect.md               # /project:architect  → T1 역할 주입
│       ├── implementor.md             # /project:implementor → T2 역할 주입
│       ├── reviewer.md                # /project:reviewer   → T3 역할 주입
│       └── devops.md                  # /project:devops     → T4 역할 주입
│
│  ═══════════════════════════════════════
│  파일 기반 통신의 핵심 허브
│  ═══════════════════════════════════════
├── docs/
│   ├── architecture.md                # 시스템 설계서      (T1이 작성, 전원 참조)
│   ├── tech-stack.md                  # 기술 스택 명세     (T1이 작성)
│   ├── questions.md                   # 설계 질의          (전원 → T1, append only)
│   ├── decisions.md                   # 아키텍처 결정 기록  (T1 기록, append only)
│   ├── tasks/
│   │   └── _template.md               # Task 명세 템플릿
│   └── reviews/
│       └── _template.md               # Review 결과 템플릿
│
│  ═══════════════════════════════════════
│  운영 도구
│  ═══════════════════════════════════════
├── scripts/
│   ├── init-project.sh                # 프로젝트 초기화
│   ├── monitor.sh                     # 실시간 상태 대시보드 (10초 간격)
│   ├── health-check.sh                # 구조 무결성 검증
│   ├── new-task.sh                    # Task 파일 자동 생성
│   └── new-review.sh                  # Review 파일 자동 생성
│
│  ═══════════════════════════════════════
│  실제 프로젝트 코드
│  ═══════════════════════════════════════
├── src/                               # 소스 코드 (T2가 구현)
├── tests/                             # 테스트 코드 (T3가 작성)
└── infra/                             # 인프라 설정 (T4가 관리)
    ├── docker/                        # Dockerfile, docker-compose
    ├── ci/                            # CI/CD 파이프라인
    └── config/                        # 환경 설정 파일
```

---

## 핵심 파일 상세 설명

### CLAUDE.md — 프로젝트 헌법

모든 터미널이 `claude` 실행 시 **자동으로 로드**하는 파일입니다. Claude Code는 프로젝트 루트의 `CLAUDE.md`를 자동 인식합니다.

| 섹션 | 내용 | 왜 필요한가 |
|------|------|------------|
| 프로젝트 개요 | 프로젝트 한 줄 설명, 기술 스택 | 모든 터미널이 동일한 맥락 공유 |
| 역할별 규칙 | 각 터미널의 할 일 / 하지 말 일 | 역할 경계 강제 (핵심) |
| 코딩 컨벤션 | strict mode, 30줄 제한, `any` 금지 등 | 일관된 코드 품질 유지 |
| 에러 핸들링 | try-catch, AppError, 응답 형식 | 표준화된 에러 처리 |
| Git 규칙 | 브랜치 네이밍, 커밋 prefix | 히스토리 추적 가능 |
| 파일 기반 통신 | 어떤 파일을 누가 쓰고 읽는지 | 비동기 협업의 프로토콜 |
| 컨텍스트 리셋 가이드 | 리셋 타이밍, 복구 방법 | 장시간 작업 시 품질 유지 |

**수정 시 주의**: 이 파일을 바꾸면 모든 터미널의 행동이 바뀝니다. Architect가 관리합니다.

### .claude/commands/*.md — 역할 진입 커맨드

Claude Code에서 `/project:architect` 처럼 입력하면 `.claude/commands/architect.md`가 시스템 프롬프트로 주입됩니다.

각 파일의 구성:

```
┌─────────────────────────────────────┐
│  # {역할} Mode 활성화               │
│                                     │
│  ## 당신의 책임                     │  ← 해야 할 일 목록
│  ## 절대 하지 않는 것               │  ← 역할 경계 (가장 중요)
│  ## 작업 시작 절차                  │  ← 매 세션 체크리스트
│  ## 완료 체크리스트                 │  ← 놓치기 쉬운 항목
│                                     │
│  현재 상태를 파악하고 보고해주세요    │  ← 자동 시작 트리거
└─────────────────────────────────────┘
```

### docs/tasks/_template.md — Task 명세서

Architect(T1)가 Implementor(T2)에게 작업을 지시하는 형식:

```markdown
# TASK-001: User 모듈 기본 구현

## 상태: PENDING                    ← 상태 필드 (자동 추적 대상)
## 담당: Terminal 2 (Implementor)
## 우선순위: HIGH
## 생성일: 2026-02-09

## 요구사항                          ← 무엇을 만들어야 하는가
- User 엔티티 정의 (Prisma schema)
- UserService: create, findByEmail, findById

## 수락 기준 (Acceptance Criteria)   ← Reviewer가 이걸로 검증
- [ ] Prisma schema에 User 모델 정의
- [ ] UserService의 3개 메서드 구현

## 참조 문서                         ← 설계 연결점
- docs/architecture.md#user-모듈

## 제약사항                          ← 지켜야 할 규칙
- any 타입 사용 금지

## 예상 영향 범위                    ← 리뷰어가 볼 파일 범위
- 파일: src/user/user.service.ts
- 모듈: user
```

### docs/reviews/_template.md — 리뷰 결과서

Reviewer(T3)가 Implementor(T2)에게 피드백하는 형식:

```markdown
# REVIEW-001: TASK-001 리뷰

## 상태: CONDITIONAL_PASS            ← 판정 결과

## 검토 항목
### 기능 정합성                      ← 수락 기준 대조
### 코드 품질                        ← 컨벤션, 복잡도
### 보안                             ← SQL Injection, XSS 등
### 성능                             ← N+1, 메모리

## 발견 이슈                         ← 구체적인 문제 목록
| 심각도    | 파일            | 라인 | 설명                  |
|-----------|----------------|------|-----------------------|
| MAJOR     | user.service.ts | 23   | 비밀번호 검증 누락     |
| MINOR     | user.service.ts | 45   | 반환 타입 불명확       |

## 재리뷰 필요 여부: YES
```

### docs/questions.md — 설계 질의

모든 터미널이 Architect에게 질문하는 **append only** 파일:

```markdown
## Q-001 (2026-02-09, Implementor)
- Task: TASK-001
- 질문: User 엔티티에 deletedAt 필드가 필요한가요?
- 상태: OPEN

### 답변 (2026-02-09, Architect)
- Soft delete 적용합니다. deletedAt: DateTime? 추가하세요.
- 상태 변경: OPEN → RESOLVED
```

### docs/decisions.md — 아키텍처 결정 기록 (ADR)

Architect가 주요 기술적 의사결정을 기록하는 **append only** 파일:

```markdown
## ADR-001: ORM으로 Prisma 선택
- 상태: ACCEPTED
### 컨텍스트: 타입 안전한 DB 접근 필요
### 결정: Prisma ORM 채택
### 근거: TypeScript 네이티브 지원, 스키마 기반 마이그레이션
### 영향: 모든 DB 접근은 Prisma Client를 통해야 함
```

---

## 역할별 상세 규칙

### T1 — Architect (두뇌)

```
┌──────────────────────────────────────────────────┐
│  🏗️  Architect                                   │
├──────────────────────────────────────────────────┤
│                                                  │
│  ✅ 하는 일                                      │
│  ─────────                                       │
│  • 프로젝트 전체 구조 설계 및 유지                │
│  • 모듈 간 인터페이스/계약 정의                   │
│  • Task Spec 작성 → docs/tasks/TASK-XXX.md       │
│  • 기술적 의사결정 기록 → docs/decisions.md       │
│  • 다른 터미널의 질의 응답 ← docs/questions.md   │
│  • docs/architecture.md 유지 관리                 │
│                                                  │
│  ❌ 하지 않는 일                                  │
│  ──────────────                                   │
│  • 직접 src/ 코드 구현                            │
│  • 테스트 코드 작성                               │
│  • 인프라 설정 변경                               │
│                                                  │
│  📁 관리 파일                                     │
│  ──────────                                       │
│  • docs/architecture.md                           │
│  • docs/tech-stack.md                             │
│  • docs/tasks/TASK-XXX.md                         │
│  • docs/decisions.md                              │
│  • docs/questions.md (답변)                       │
│  • CLAUDE.md                                      │
│                                                  │
└──────────────────────────────────────────────────┘
```

### T2 — Implementor (손)

```
┌──────────────────────────────────────────────────┐
│  💻  Implementor                                 │
├──────────────────────────────────────────────────┤
│                                                  │
│  ✅ 하는 일                                      │
│  ─────────                                       │
│  • docs/tasks/에서 PENDING Task를 구현            │
│  • 비즈니스 로직, API, DB 스키마 작성             │
│  • CLAUDE.md 코딩 컨벤션 엄격 준수               │
│  • 구현 완료 시 Task 상태 → REVIEW 변경          │
│  • 설계 의문 → docs/questions.md에 기록          │
│                                                  │
│  ❌ 하지 않는 일                                  │
│  ──────────────                                   │
│  • 아키텍처/설계 임의 변경                        │
│  • 테스트 코드 작성 (T3의 역할)                   │
│  • 인프라/Docker 설정 변경                        │
│  • Task Spec에 없는 기능 추가                     │
│                                                  │
│  📁 관리 파일                                     │
│  ──────────                                       │
│  • src/ 전체                                      │
│  • docs/tasks/TASK-XXX.md (상태 변경만)           │
│  • docs/questions.md (질의 추가)                  │
│                                                  │
└──────────────────────────────────────────────────┘
```

### T3 — Reviewer / QA (눈)

```
┌──────────────────────────────────────────────────┐
│  🔍  Reviewer / QA                               │
├──────────────────────────────────────────────────┤
│                                                  │
│  ✅ 하는 일                                      │
│  ─────────                                       │
│  • REVIEW 상태 Task의 구현 코드 검토              │
│  • 리뷰 관점 (우선순위 순):                       │
│    1. 정확성 — 수락 기준 충족 여부                │
│    2. 보안   — SQL Injection, XSS, 인증/인가     │
│    3. 에러   — 엣지 케이스, 예외 처리             │
│    4. 성능   — N+1, 메모리 누수                  │
│    5. 가독성 — 네이밍, 구조, 복잡도               │
│    6. 컨벤션 — CLAUDE.md 규칙 준수               │
│  • docs/reviews/REVIEW-XXX.md 작성               │
│  • PASS / FAIL / CONDITIONAL_PASS 판정           │
│  • 테스트 코드 작성 전담 (tests/)                │
│                                                  │
│  ❌ 하지 않는 일                                  │
│  ──────────────                                   │
│  • 소스 코드 직접 수정 (피드백만 작성)            │
│  • 새로운 기능 구현                               │
│  • 설계 변경                                      │
│                                                  │
│  📁 관리 파일                                     │
│  ──────────                                       │
│  • docs/reviews/REVIEW-XXX.md                     │
│  • tests/ 전체                                    │
│                                                  │
└──────────────────────────────────────────────────┘
```

### T4 — DevOps (다리)

```
┌──────────────────────────────────────────────────┐
│  🚀  DevOps / Infra                              │
├──────────────────────────────────────────────────┤
│                                                  │
│  ✅ 하는 일                                      │
│  ─────────                                       │
│  • Docker/docker-compose 설정 관리                │
│  • CI/CD 파이프라인 구성                          │
│  • 개발/스테이징/프로덕션 환경 설정               │
│  • 빌드, 린트, 테스트 자동화 스크립트             │
│  • 환경변수 및 시크릿 관리                        │
│                                                  │
│  ❌ 하지 않는 일                                  │
│  ──────────────                                   │
│  • src/ 비즈니스 로직 변경                        │
│  • 테스트 로직 변경                               │
│  • 아키텍처 설계 변경                             │
│                                                  │
│  📁 관리 파일                                     │
│  ──────────                                       │
│  • infra/ 전체                                    │
│  • docker-compose*.yml                            │
│  • Dockerfile*                                    │
│  • .github/workflows/ (CI)                        │
│  • scripts/ (빌드/배포 스크립트)                  │
│  • .env.example                                   │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## 협업 흐름도

### 전체 사이클

```
                         ┌─────────────────┐
                         │  T1 Architect    │
                         │  설계 수립       │
                         └────────┬────────┘
                                  │
                        Task Spec 작성
                    docs/tasks/TASK-XXX.md
                                  │
                                  ▼
                         ┌─────────────────┐
                ┌────────│  T2 Implementor │◄───────────┐
                │        │  코드 구현       │            │
                │        └────────┬────────┘            │
                │                 │                     │
            설계 질의        상태 → REVIEW          FAIL 피드백
        docs/questions.md         │              수정 후 재제출
                │                 ▼                     │
                │        ┌─────────────────┐            │
                │        │  T3 Reviewer    │────────────┘
                │        │  코드 리뷰       │
                │        │  테스트 작성     │
                │        └────────┬────────┘
                │                 │
                │            PASS 판정
                ▼                 │
         ┌─────────────────┐     ▼
         │  T1 Architect   │  ┌─────────────────┐
         │  질의 응답       │  │  T4 DevOps      │
         └─────────────────┘  │  빌드/배포       │
                              │  통합 검증       │
                              └─────────────────┘
```

### 터미널 간 데이터 흐름

```
T1 Architect ──── docs/tasks/TASK-XXX.md ────────► T2 Implementor
                                                        │
T1 Architect ◄──── docs/questions.md ───────────── T2 Implementor
                                                        │
                                                  Task 상태 → REVIEW
                                                        │
                                                        ▼
T2 Implementor ◄── docs/reviews/REVIEW-XXX.md ─── T3 Reviewer
                   (FAIL 시 수정 요청)                   │
                                                        │
                                                  tests/ 테스트 코드
                                                        │
                                                   PASS 판정
                                                        │
                                                        ▼
                                                   T4 DevOps
                                                  빌드 & 배포 검증
```

---

## 파일 기반 통신 체계

터미널 간에는 **직접 통신이 불가능**합니다. 파일 시스템을 메시지 큐처럼 사용합니다.

### 통신 경로 매트릭스

| 파일 | 작성자 | 수신자 | 규칙 |
|------|--------|--------|------|
| `docs/tasks/TASK-XXX.md` | T1 Architect | T2 Implementor | T1만 생성, T2가 상태 변경 |
| `docs/reviews/REVIEW-XXX.md` | T3 Reviewer | T2 Implementor | T3만 생성/수정 |
| `docs/questions.md` | 전원 | T1 Architect | **append only** (기존 내용 수정 금지) |
| `docs/decisions.md` | T1 Architect | 전원 (참조) | **append only** |
| `docs/architecture.md` | T1 Architect | 전원 (참조) | T1만 수정 |

### 비동기 협업의 원리

```
시간 →
T1: [Task작성]                        [질의응답]         [머지판단]
T2:            [Task읽기] → [구현중...] → [REVIEW]            [수정]
T3:                                        [리뷰] → [PASS]
T4:                         [인프라설정]              [빌드검증]
```

각 터미널은 **시작할 때 docs/ 디렉토리를 확인**하고 자신이 처리할 항목이 있는지 찾습니다.
`/project:{역할}` 커맨드의 마지막 줄이 이 동작을 트리거합니다:

> "현재 프로젝트 상태를 파악하고, 어떤 작업이 필요한지 보고해주세요."

---

## Task 생명주기

### 상태 전이 다이어그램

```
┌─────────┐    T2 착수    ┌──────────────┐    T2 완료    ┌─────────┐
│ PENDING │──────────────►│ IN_PROGRESS  │──────────────►│ REVIEW  │
└─────────┘               └──────────────┘               └────┬────┘
                                  ▲                           │
                                  │                     ┌─────┴─────┐
                                  │                     │           │
                             T2 수정 후             T3: FAIL    T3: PASS
                             재제출                     │           │
                                  │                     │      ┌────▼────┐
                                  └─────────────────────┘      │  DONE   │
                                                               └─────────┘
```

### 각 상태에서 일어나는 일

| 상태 | 책임 터미널 | 동작 |
|------|------------|------|
| **PENDING** | T1 생성 → T2 대기 | Architect가 Task를 만들고, Implementor가 가져감 |
| **IN_PROGRESS** | T2 | Implementor가 코드를 작성 중 |
| **REVIEW** | T3 | Reviewer가 코드를 검토하고 테스트를 작성 |
| **DONE** | — | 리뷰 통과 + 빌드 검증 완료. 최종 상태 |

### 리뷰 판정 기준

| 판정 | 의미 | 다음 단계 |
|------|------|----------|
| **PASS** | 모든 검토 항목 통과 | Task → DONE, T4 통합 검증 |
| **CONDITIONAL_PASS** | 경미한 이슈만 존재 (MINOR) | T2가 수정 후 T3가 간략 재검증 |
| **FAIL** | CRITICAL 또는 MAJOR 이슈 존재 | T2가 수정 후 Task → REVIEW로 재제출 |

---

## 유틸리티 스크립트

### `scripts/init-project.sh` — 프로젝트 초기화

```bash
./scripts/init-project.sh
```

- 필요한 디렉토리 구조 생성 (없는 것만)
- 빈 디렉토리에 `.gitkeep` 추가
- 스크립트 실행 권한 부여
- 다음 단계 안내 출력

### `scripts/monitor.sh` — 실시간 상태 대시보드

```bash
./scripts/monitor.sh
```

10초마다 갱신되는 컬러 대시보드:

```
=======================================
 Multi-Terminal Project Monitor
 2026-02-09 14:30:15
=======================================

[Tasks]
  REVIEW       TASK-001
  PENDING      TASK-002
  IN_PROGRESS  TASK-003
  DONE         TASK-000

  Summary: 1 pending | 1 in progress | 1 in review | 1 done

[Reviews]
  CONDITIONAL_PASS   REVIEW-001

[Open Questions]
  2 open question(s)

=======================================
 Notifications
=======================================
  >> Terminal 3 (Reviewer): 1 task(s) awaiting review!
  >> Terminal 2 (Implementor): 1 task(s) pending!
  >> Terminal 1 (Architect): Open questions need answers!
  >> Terminal 2 (Implementor): 1 review(s) need fixes!
```

**역할별 알림**을 통해 각 터미널이 언제 행동해야 하는지 알 수 있습니다.

### `scripts/health-check.sh` — 구조 검증

```bash
./scripts/health-check.sh
```

검증 항목:
- 핵심 파일 존재 여부 (CLAUDE.md, architecture.md 등)
- 템플릿 파일 존재 여부
- 슬래시 커맨드 파일 존재 여부
- 디렉토리 구조 완전성
- 스크립트 실행 권한
- CLAUDE.md 내용 검증 (역할 규칙, 코딩 컨벤션, Git 규칙 섹션)

### `scripts/new-task.sh` — Task 파일 생성 헬퍼

```bash
./scripts/new-task.sh "User 모듈 기본 구현"
# → docs/tasks/TASK-001.md 생성 (번호 자동 증가)
```

- 템플릿에서 자동 생성
- Task 번호 순차 증가 (001, 002, ...)
- 날짜 자동 입력
- 상태를 `PENDING`으로 초기화

### `scripts/new-review.sh` — Review 파일 생성 헬퍼

```bash
./scripts/new-review.sh TASK-001
# → docs/reviews/REVIEW-001.md 생성
```

- Task 번호에 맞는 Review 파일 생성
- 기존 파일이 있으면 덮어쓸지 확인

---

## Git 브랜치 전략

### 브랜치 구조

```
main                                            ← 프로덕션 (T1이 승격 결정)
 └── develop                                    ← 통합 브랜치
      ├── feat/TASK-001-user-module             ← T2 (구현)
      ├── feat/TASK-002-auth-service            ← T2 (구현)
      ├── test/TASK-001-user-tests              ← T3 (테스트)
      ├── infra/docker-setup                    ← T4 (인프라)
      └── docs/architecture-v2                  ← T1 (설계)
```

### 브랜치 네이밍 규칙

| 터미널 | 접두사 | 예시 |
|--------|--------|------|
| T1 Architect | `docs/` | `docs/architecture-v2` |
| T2 Implementor | `feat/` | `feat/TASK-001-user-module` |
| T3 Reviewer | `test/` | `test/TASK-001-user-tests` |
| T4 DevOps | `infra/` | `infra/docker-setup` |

### 커밋 메시지 형식

```
[역할] type: 설명

예시:
[arch] docs: define auth module interface
[impl] feat: implement user CRUD service
[impl] fix: resolve email validation edge case
[review] test: add user service unit tests
[review] test: add integration tests for auth flow
[infra] chore: configure docker-compose for dev
[infra] ci: add GitHub Actions workflow
```

### Merge 규칙

```
T2 feat/* ──── 리뷰 PASS ────► develop     (T1이 merge 판단)
T3 test/* ──── 해당 feat/*에 merge ──────►  (T3이 테스트 브랜치를 feat에 합침)
T4 infra/* ─── 직접 ──────────► develop     (T1 승인 후)
develop ────── 안정화 확인 ───► main        (T1이 승격 결정)
```

---

## 컨텍스트 리셋 전략

### 왜 리셋이 필요한가

Claude Code의 컨텍스트 윈도우는 유한합니다. 대화가 길어지면:
- 초기에 부여한 역할 지시를 잊습니다
- 코딩 컨벤션을 점점 지키지 않습니다
- 역할 경계가 흐려져서 Implementor가 설계를 바꾸기 시작합니다

### 리셋 타이밍

| 조건 | 권장 |
|------|------|
| Task 1개 완료 | 리셋 (자연스러운 경계) |
| 대화 30턴 초과 | 리셋 |
| 역할 벗어난 응답 시작 | 즉시 리셋 |
| 대규모 모듈 완성 | 리셋 |

### 리셋 방법

```bash
# Claude Code 내에서
/clear                    # 컨텍스트 초기화
/project:implementor      # 역할 재진입
```

### 왜 파일 기반 통신이 리셋에 강한가

```
리셋 전:
  Claude의 메모리   →  "TASK-001 구현 중, 23번 줄에서 막힘"  (휘발성)
  docs/tasks/       →  "TASK-001: 상태 IN_PROGRESS"          (영속적)

리셋 후:
  Claude의 메모리   →  (비어있음)
  docs/tasks/       →  "TASK-001: 상태 IN_PROGRESS"          (그대로!)

/project:implementor 실행 → docs/ 읽기 → 즉시 이어서 작업
```

**모든 상태가 파일에 기록되어 있으므로 컨텍스트가 사라져도 프로젝트 상태는 살아있습니다.** 이것이 파일 기반 통신 설계의 핵심 장점입니다.

---

## 실전 운영 시나리오

### 시나리오: "사용자 인증 API" 개발

#### Phase 1 — Architect가 설계 수립 (Terminal 1)

```
> 사용자 인증 API를 설계해주세요.
> 요구사항: 회원가입, 로그인, 토큰 갱신
> PostgreSQL + Redis + JWT 기반
>
> 1. docs/architecture.md에 auth 모듈 추가
> 2. docs/tasks/TASK-001.md 생성
```

Architect 산출물:
- `docs/architecture.md` — auth 모듈 설계 추가
- `docs/tasks/TASK-001.md` — "User 모듈 기본 구현" (상태: PENDING)
- `docs/tasks/TASK-002.md` — "Auth 서비스 구현" (상태: PENDING)
- `docs/decisions.md` — "ADR-001: JWT + Refresh Token 전략"

#### Phase 2 — Implementor가 구현 (Terminal 2)

```
> docs/tasks/에서 PENDING 상태인 Task를 확인하고 구현해주세요.
```

Implementor 동작:
1. TASK-001 읽기 → 상태를 IN_PROGRESS로 변경
2. `src/user/user.service.ts` 구현
3. `prisma/schema.prisma` 수정
4. 설계 의문 발생 → `docs/questions.md`에 Q-001 추가
5. 구현 완료 → 상태를 REVIEW로 변경
6. `git commit -m "[impl] feat: implement user module"`

#### Phase 3 — Architect가 질의 응답 (Terminal 1)

```
> docs/questions.md에 미응답 질의가 있는지 확인하고 답변해주세요.
```

#### Phase 4 — Reviewer가 검증 (Terminal 3)

```
> REVIEW 상태인 Task를 확인하고 코드 리뷰 + 테스트를 작성해주세요.
```

Reviewer 동작:
1. TASK-001 (REVIEW) 확인
2. `src/user/user.service.ts` 전체 읽기
3. 리뷰 체크리스트 기반 검토
4. `docs/reviews/REVIEW-001.md` 작성 → CONDITIONAL_PASS
5. `tests/user/user.service.spec.ts` 테스트 작성
6. `git commit -m "[review] test: add user service unit tests"`

#### Phase 5 — 피드백 순환 (Terminal 2 ↔ Terminal 3)

Terminal 2:
```
> docs/reviews/REVIEW-001.md를 확인하고 지적사항을 수정해주세요.
```

Terminal 3:
```
> REVIEW-001의 지적사항이 수정되었는지 재검증해주세요.
> 통과하면 PASS로 변경해주세요.
```

#### Phase 6 — DevOps가 통합 검증 (Terminal 4)

```
> 전체 빌드와 테스트를 실행해주세요.
> Docker 환경에서도 정상 동작하는지 확인해주세요.
```

---

## 체크리스트: 매 세션 시작 시

| 순서 | 터미널 | 확인 사항 |
|------|--------|----------|
| 1 | 전체 | CLAUDE.md 최신 상태 확인 |
| 2 | T1 | `docs/questions.md` 미응답 질의 확인 |
| 3 | T1 | 전체 Task 상태 점검, 다음 Task 생성 |
| 4 | T2 | `docs/tasks/`에서 PENDING Task 확인 → 구현 시작 |
| 5 | T2 | `docs/reviews/`에서 FAIL 피드백 확인 → 수정 |
| 6 | T3 | `docs/tasks/`에서 REVIEW Task 확인 → 리뷰 시작 |
| 7 | T4 | 빌드/테스트 상태 점검 |
| 8 | 모니터 | `./scripts/monitor.sh` 실행 |

> 각 `/project:{역할}` 커맨드가 이 절차를 자동으로 안내합니다.

---

## 커스터마이징 가이드

이 보일러플레이트를 프로젝트에 적용할 때 수정이 필요한 부분:

### 반드시 수정

| 파일 | 수정 내용 |
|------|----------|
| `CLAUDE.md` | 프로젝트 개요, 기술 스택, 코딩 컨벤션을 실제 프로젝트에 맞게 |
| `docs/architecture.md` | 시스템 구조, 모듈 정의, 데이터 모델 |
| `docs/tech-stack.md` | 실제 사용하는 기술 스택 |

### 선택적 수정

| 파일 | 수정 내용 |
|------|----------|
| `.claude/commands/*.md` | 역할별 추가 규칙이나 체크리스트 |
| `docs/tasks/_template.md` | 프로젝트 특화 필드 추가 |
| `docs/reviews/_template.md` | 리뷰 체크리스트 커스터마이징 |
| `.gitignore` | 프로젝트 특화 무시 패턴 |

### 터미널 추가 (5개 체제)

Terminal 5를 추가하려면:

1. `.claude/commands/documentation.md` 생성 (역할 정의)
2. `CLAUDE.md`에 역할 규칙 추가
3. 필요한 `docs/` 하위 디렉토리 추가

---

## FAQ

### Q: 혼자 작업할 때도 4개 터미널이 필요한가요?

최소 T1(설계) + T2(구현) + T3(리뷰) 3개를 권장합니다. 특히 **구현과 리뷰의 분리**가 가장 큰 품질 향상을 가져옵니다. DevOps는 초기에는 Architect가 겸할 수 있습니다.

### Q: 터미널을 동시에 실행해야 하나요?

아닙니다. **비동기 협업**이 핵심입니다. T1에서 Task를 만들고 닫은 뒤, T2를 열어서 구현해도 됩니다. 파일에 모든 상태가 남아있으므로 순차적으로 진행해도 동작합니다.

### Q: 실수로 역할을 벗어나면 어떻게 하나요?

`/clear` → `/project:{역할}` 로 리셋하세요. CLAUDE.md와 각 커맨드 파일에 "절대 하지 않는 것" 목록이 있어서, 역할 이탈 시 Claude가 스스로 거부하도록 설계되어 있습니다.

### Q: 작은 프로젝트에도 이 구조가 적합한가요?

구조는 오버헤드처럼 보일 수 있지만, 핵심은 **역할 분리**입니다. `docs/tasks/`와 `docs/reviews/`만 사용하더라도 구현-리뷰 사이클의 품질이 크게 향상됩니다.

### Q: 기존 프로젝트에 적용할 수 있나요?

기존 프로젝트 루트에서 `./scripts/init-project.sh`를 실행하면 필요한 디렉토리와 파일만 추가됩니다. 기존 `src/`, `tests/` 등은 건드리지 않습니다. `CLAUDE.md`만 프로젝트에 맞게 작성하면 바로 적용 가능합니다.
