# 기술 스택 명세

> 이 문서는 Architect (Terminal 1)가 관리합니다.
> 프로젝트 시작 시 실제 기술 스택으로 업데이트하세요.

## Runtime
- **언어**: TypeScript 5.x (strict mode)
- **런타임**: Node.js 20 LTS

## Framework
- **백엔드**: (프로젝트에 맞게 선택)
- **프론트엔드**: (필요 시)

## 데이터베이스
- **Primary DB**: PostgreSQL 16
- **ORM**: Prisma
- **Cache**: Redis 7

## 테스트
- **프레임워크**: Jest
- **API 테스트**: Supertest
- **커버리지 목표**: 라인 80% 이상

## 빌드 & 배포
- **컨테이너**: Docker + docker-compose
- **CI/CD**: (GitHub Actions / GitLab CI / etc.)
- **패키지 매니저**: (npm / pnpm / yarn)

## 코드 품질
- **린터**: ESLint
- **포매터**: Prettier
- **타입 체크**: tsc --noEmit

## 외부 서비스
> 연동하는 외부 API, 서비스를 목록화하세요.
- (목록)
