# 프로젝트 분석 보고서

> 분석일: 2026-03-31

## 프로젝트 개요

**Claude Code 멀티 터미널 역할 분담 전략 템플릿**

4개의 터미널에서 각각 다른 역할(Architect, Implementor, Reviewer, DevOps)을 맡아 협업하는 워크플로우 템플릿 프로젝트입니다.

## 현재 상태: 초기 템플릿 (미구성)

- `src/`, `tests/`, `infra/` 디렉토리는 `.gitkeep`만 존재 (실제 코드 없음)
- `docs/` 문서들은 모두 템플릿/placeholder 상태
- 기술 스택, 아키텍처 등이 아직 실제 프로젝트에 맞게 커스터마이즈되지 않음
- Task, Review 문서 없음 (작업 이력 없음)
- 미응답 질의 없음

## 디렉토리 구조

| 디렉토리 | 용도 | 상태 |
|----------|------|------|
| `src/` | 비즈니스 코드 | 비어있음 (.gitkeep만 존재) |
| `tests/` | 테스트 코드 | 비어있음 (.gitkeep만 존재) |
| `infra/docker/` | Docker 설정 | 비어있음 (.gitkeep만 존재) |
| `infra/ci/` | CI/CD 설정 | 비어있음 (.gitkeep만 존재) |
| `infra/config/` | 인프라 설정 | 비어있음 (.gitkeep만 존재) |
| `docs/` | 설계 문서, Task, 리뷰 | 템플릿만 존재 |
| `docs/tasks/` | 작업 지시 문서 | 템플릿만 존재 (`_template.md`) |
| `docs/reviews/` | 리뷰 결과 문서 | 템플릿만 존재 (`_template.md`) |
| `scripts/` | 프로젝트 유틸리티 | 4개 스크립트 존재 |
| `.claude/commands/` | 역할별 슬래시 커맨드 | 4개 역할 정의 완료 |

## 역할 분담 체계

| 역할 | 터미널 | 핵심 책임 | 커밋 prefix | 제한사항 |
|------|--------|-----------|------------|----------|
| Architect | 1 | 설계, Task Spec 작성, 의사결정 기록, 질의 응답 | - | 코드 직접 구현 금지 |
| Implementor | 2 | Task 기반 코드 구현 | `[impl]` | 설계 임의 변경 금지 |
| Reviewer | 3 | 코드 리뷰, 테스트 작성, PASS/FAIL 판정 | `[review]` | 코드 직접 수정 금지 |
| DevOps | 4 | 인프라, CI/CD, Docker 설정 | `[infra]` | `src/` 비즈니스 코드 변경 금지 |

## 기술 스택 (템플릿 기본값)

- **Runtime**: Node.js 20 LTS / TypeScript 5.x (strict mode)
- **DB**: PostgreSQL 16 + Prisma ORM
- **Cache**: Redis 7
- **Test**: Jest + Supertest (커버리지 목표: 라인 80% 이상)
- **인프라**: Docker + docker-compose
- **코드 품질**: ESLint + Prettier + `tsc --noEmit`

## 워크플로우

```
Architect → Task Spec 작성 (PENDING)
    ↓
Implementor → 구현 (IN_PROGRESS → REVIEW)
    ↓
Reviewer → 리뷰 (PASS / FAIL / CONDITIONAL_PASS)
    ↓
FAIL → Implementor 수정 → 재리뷰
PASS → DONE
```

## 파일 기반 통신 규칙

| 용도 | 경로 | 작성자 | 비고 |
|------|------|--------|------|
| 작업 지시 | `docs/tasks/TASK-XXX.md` | Architect | 템플릿 기반 |
| 리뷰 결과 | `docs/reviews/REVIEW-XXX.md` | Reviewer | PASS/FAIL/CONDITIONAL_PASS |
| 설계 질의 | `docs/questions.md` | 전원 | append only |
| 결정 기록 | `docs/decisions.md` | Architect | append only, ADR 형식 |

## 유틸리티 스크립트

| 스크립트 | 용도 |
|----------|------|
| `scripts/init-project.sh` | 디렉토리 구조 초기화 |
| `scripts/monitor.sh` | 10초 간격 상태 모니터링 (Task/Review/Question 현황) |
| `scripts/new-task.sh` | 새 Task 문서 생성 |
| `scripts/new-review.sh` | 새 Review 문서 생성 |
| `scripts/health-check.sh` | 프로젝트 상태 점검 |

## 코딩 컨벤션 요약

- TypeScript strict mode 필수
- 함수: 단일 책임, 30줄 이하
- 네이밍: camelCase (변수/함수), PascalCase (클래스/인터페이스/타입)
- 모든 public 함수에 JSDoc 필수
- `any` 타입 사용 금지 → `unknown` 사용
- magic number 금지 (상수로 추출)
- `console.log` 금지 (Logger 사용)
- 모든 외부 호출은 try-catch로 감싸기

## 다음 단계 (프로젝트 시작을 위해 필요한 작업)

1. 실제 프로젝트 목적 정의 및 `CLAUDE.md` 수정
2. `docs/architecture.md` 실제 시스템 구조로 작성
3. `docs/tech-stack.md` 실제 기술 스택으로 업데이트
4. 첫 번째 Task Spec 작성 (`docs/tasks/TASK-001.md`)
5. 프로젝트 초기화 (`package.json`, `tsconfig.json` 등)
6. Docker 및 CI/CD 파이프라인 구성
