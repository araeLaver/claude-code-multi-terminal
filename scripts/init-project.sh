#!/bin/bash
# scripts/init-project.sh
# 새 프로젝트에 멀티 터미널 구조를 초기화하는 스크립트
#
# 사용법:
#   1. 이 저장소를 복제합니다
#   2. 프로젝트 루트에서 ./scripts/init-project.sh 실행
#   3. CLAUDE.md를 프로젝트에 맞게 수정합니다
#   4. 각 터미널에서 claude 실행 후 /project:{역할} 로 역할 진입

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BOLD}Multi-Terminal Strategy - Project Initializer${NC}"
echo "=============================================="
echo ""

# 디렉토리 구조 확인 및 생성
dirs=(
    "docs/tasks"
    "docs/reviews"
    ".claude/commands"
    "scripts"
    "src"
    "tests"
    "infra/docker"
    "infra/ci"
    "infra/config"
)

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "  ${GREEN}Created${NC} $dir/"
    else
        echo "  Exists  $dir/"
    fi
done

# .gitkeep 파일 추가 (빈 디렉토리 유지용)
gitkeep_dirs=("src" "tests" "infra/docker" "infra/ci" "infra/config")
for dir in "${gitkeep_dirs[@]}"; do
    if [ ! -f "$dir/.gitkeep" ]; then
        touch "$dir/.gitkeep"
        echo -e "  ${GREEN}Added${NC}   $dir/.gitkeep"
    fi
done

# 실행 권한 부여
chmod +x scripts/*.sh 2>/dev/null || true

echo ""
echo -e "${BOLD}=============================================="
echo -e "Setup Complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Edit CLAUDE.md to match your project"
echo "  2. Edit docs/architecture.md with your system design"
echo "  3. Edit docs/tech-stack.md with your technology choices"
echo ""
echo -e "${CYAN}Start working:${NC}"
echo "  Terminal 1: claude → /project:architect"
echo "  Terminal 2: claude → /project:implementor"
echo "  Terminal 3: claude → /project:reviewer"
echo "  Terminal 4: claude → /project:devops"
echo ""
echo -e "${CYAN}Monitor status:${NC}"
echo "  ./scripts/monitor.sh"
echo ""
