# Claude Code Multi-Terminal Strategy

Claude Code 멀티 터미널 역할 분담 전략의 **템플릿/보일러플레이트** 저장소입니다.

이 구조를 복제하여 어떤 프로젝트든 역할이 분리된 멀티 터미널 워크플로우로 시작할 수 있습니다.

## 핵심 원칙

단일 Claude Code 인스턴스로 모든 작업을 처리하면 **컨텍스트 윈도우 오염**과 **역할 혼재**로 인한 품질 저하가 발생합니다.
터미널을 역할별로 분리하면 각 인스턴스가 자신의 도메인에 집중하면서 컨텍스트를 효율적으로 사용할 수 있습니다.

## 4-Terminal 체제

| Terminal | 역할 | 책임 |
|----------|------|------|
| T1 | **Architect** | 설계, Task Spec 작성, 오케스트레이션 |
| T2 | **Implementor** | 핵심 비즈니스 로직 구현 |
| T3 | **Reviewer** | 코드 리뷰, 테스트 작성, QA |
| T4 | **DevOps** | 인프라, CI/CD, 빌드/배포 |

## Quick Start

```bash
# 1. 이 저장소를 복제
git clone <this-repo> my-project
cd my-project

# 2. 프로젝트 구조 초기화
./scripts/init-project.sh

# 3. 프로젝트에 맞게 설정 파일 수정
#    - CLAUDE.md (프로젝트 규칙)
#    - docs/architecture.md (시스템 설계)
#    - docs/tech-stack.md (기술 스택)

# 4. 각 터미널에서 Claude Code 시작
# Terminal 1:
claude
/project:architect

# Terminal 2:
claude
/project:implementor

# Terminal 3:
claude
/project:reviewer

# Terminal 4:
claude
/project:devops

# 5. (선택) 모니터 실행
./scripts/monitor.sh
```

## 디렉토리 구조

```
project-root/
├── CLAUDE.md                      # 프로젝트 헌법 (모든 터미널 필독)
├── .claude/
│   └── commands/                  # 역할별 슬래시 커맨드
│       ├── architect.md           # /project:architect
│       ├── implementor.md         # /project:implementor
│       ├── reviewer.md            # /project:reviewer
│       └── devops.md              # /project:devops
├── docs/
│   ├── architecture.md            # 시스템 아키텍처 (T1 관리)
│   ├── tech-stack.md              # 기술 스택 명세
│   ├── tasks/                     # Task Specs (T1 → T2)
│   │   └── _template.md
│   ├── reviews/                   # Review Results (T3 → T2)
│   │   └── _template.md
│   ├── questions.md               # 설계 질의 (전원 → T1)
│   └── decisions.md               # ADR (T1 기록)
├── scripts/
│   ├── init-project.sh            # 프로젝트 초기화
│   ├── monitor.sh                 # 상태 모니터링
│   ├── health-check.sh            # 구조 검증
│   ├── new-task.sh                # Task 생성 헬퍼
│   └── new-review.sh              # Review 생성 헬퍼
├── src/                           # 소스 코드
├── tests/                         # 테스트 코드
└── infra/                         # 인프라 설정
    ├── docker/
    ├── ci/
    └── config/
```

## 협업 플로우

```
Terminal 1 (Architect)
    │
    ├── Task Spec 작성 → docs/tasks/
    │
    ▼
Terminal 2 (Implementor)
    │
    ├── 구현 완료 → git commit
    │
    ▼
Terminal 3 (Reviewer)
    │
    ├── 리뷰 결과 → docs/reviews/
    │   ├── PASS → Terminal 4로
    │   └── FAIL → Terminal 2로 피드백
    │
    ▼
Terminal 4 (DevOps)
    │
    └── 빌드/테스트 실행 → 결과 보고
```

## 파일 기반 통신

터미널 간에는 직접 통신이 불가능하므로 **파일 시스템을 메시지 큐처럼** 사용합니다.

| 용도 | 경로 | 작성자 → 수신자 |
|------|------|----------------|
| 작업 지시 | `docs/tasks/TASK-XXX.md` | T1 → T2 |
| 리뷰 결과 | `docs/reviews/REVIEW-XXX.md` | T3 → T2 |
| 설계 질의 | `docs/questions.md` | 전원 → T1 |
| 결정 기록 | `docs/decisions.md` | T1 (기록용) |

각 터미널 시작 시 **"docs/ 디렉토리를 확인하고 자신의 역할에 해당하는 최신 문서를 읽어라"**고 지시하면 비동기 협업이 가능합니다.

## 유틸리티 스크립트

```bash
# 새 Task 생성
./scripts/new-task.sh "User 모듈 기본 구현"

# 새 Review 생성
./scripts/new-review.sh TASK-001

# 프로젝트 상태 모니터링
./scripts/monitor.sh

# 구조 건강 검진
./scripts/health-check.sh
```

## 컨텍스트 리셋 관리

Claude Code의 컨텍스트 윈도우는 유한합니다. 아래 시점에서 리셋을 권장합니다:

- Task 1개 완료할 때마다
- 대화가 30턴을 넘어갈 때
- Claude의 응답이 역할을 벗어나기 시작할 때

리셋 후 `/project:{역할}` 커맨드로 즉시 역할을 복구할 수 있습니다.
CLAUDE.md와 docs/ 에 모든 상태가 파일로 남아있으므로 컨텍스트 손실이 없습니다.

## Git 브랜치 전략

```
main
 └── develop
      ├── feat/TASK-001-user-module        ← Terminal 2
      ├── test/TASK-001-user-tests         ← Terminal 3
      ├── infra/docker-setup               ← Terminal 4
      └── docs/architecture-v1             ← Terminal 1
```

- Terminal 1 (Architect)이 merge 판단을 내립니다
- 리뷰 PASS 후 develop에 merge
- develop → main 승격은 Architect가 결정
