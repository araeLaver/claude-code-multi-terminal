# Multi-Terminal Role Division Strategy

## 프로젝트 개요
이 프로젝트는 Claude Code 멀티 터미널 역할 분담 전략의 템플릿입니다.
프로젝트를 복제한 후 이 섹션을 실제 프로젝트 설명으로 교체하세요.

## 기술 스택
> 아래는 예시입니다. 프로젝트에 맞게 수정하세요.
- Runtime: Node.js 20 / TypeScript 5.x
- Framework: (프로젝트에 맞게 선택)
- Database: PostgreSQL 16 + Prisma ORM
- Cache: Redis 7
- Test: Jest + Supertest
- Container: Docker + docker-compose

## 역할별 규칙

### 🏗️ Architect (Terminal 1)
- 시스템 설계, 모듈 분리, 인터페이스 정의 전담
- 모든 설계 변경은 `docs/architecture.md`에 반영 필수
- Task Spec을 `docs/tasks/TASK-XXX.md`로 작성
- 다른 터미널의 질의(`docs/questions.md`)에 응답
- 구현 코드를 직접 작성하지 않음

### 💻 Implementor (Terminal 2)
- `docs/tasks/`의 Task Spec 기반으로만 구현
- 설계 변경을 임의로 하지 않음
- 설계 의문점은 `docs/questions.md`에 기록
- 구현 완료 시 Task 상태를 `REVIEW`로 변경
- 커밋 prefix: `[impl]`

### 🔍 Reviewer (Terminal 3)
- 상태가 `REVIEW`인 Task만 검토
- 코드를 직접 수정하지 않음 (피드백만 작성)
- `docs/reviews/REVIEW-XXX.md`에 리뷰 결과 기록
- `PASS` / `FAIL` / `CONDITIONAL_PASS` 판정
- 테스트 코드 작성 전담
- 커밋 prefix: `[review]`

### 🚀 DevOps (Terminal 4)
- `src/` 디렉토리의 비즈니스 코드 변경 금지
- `infra/`, `docker/`, CI 설정만 담당
- 빌드 실패 시 원인 분석 후 `docs/`에 기록
- 커밋 prefix: `[infra]`

## 코딩 컨벤션
- TypeScript strict mode 필수
- 함수: 단일 책임, 30줄 이하
- 네이밍: camelCase (변수/함수), PascalCase (클래스/인터페이스/타입)
- 모든 public 함수에 JSDoc 필수
- `any` 타입 사용 금지 (`unknown` 사용)
- magic number 금지 (상수로 추출)
- `console.log` 금지 (Logger 사용)

## 에러 핸들링
- 모든 외부 호출은 try-catch로 감싸기
- 커스텀 에러 클래스 사용 (AppError 상속)
- 에러 응답 형식: `{ code, message, details }`

## Git 규칙
- 브랜치: `feat/{task-number}-{설명}`
- 커밋 형식: `[역할] type: 설명`
  ```
  [impl] feat: add user authentication service
  [review] test: add unit tests for auth service
  [infra] chore: configure docker-compose for dev
  ```
- 하나의 커밋에 하나의 논리적 변경만 포함

## 파일 기반 통신 규칙
| 용도 | 경로 | 작성자 |
|------|------|--------|
| 작업 지시 | `docs/tasks/TASK-XXX.md` | Architect |
| 리뷰 결과 | `docs/reviews/REVIEW-XXX.md` | Reviewer |
| 설계 질의 | `docs/questions.md` | 전원 (append only) |
| 결정 기록 | `docs/decisions.md` | Architect (append only) |

상태 변경 시 해당 문서의 `## 상태` 필드를 업데이트합니다.

## 컨텍스트 리셋 가이드
- Task 1개 완료할 때마다 리셋 권장
- 대화가 30턴을 넘어가면 리셋
- `/clear` 후 `/project:{역할}` 로 역할 재진입
- CLAUDE.md와 docs/ 에 모든 상태가 기록되어 있으므로 즉시 복구 가능
