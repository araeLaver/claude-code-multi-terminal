#!/bin/bash
# scripts/health-check.sh
# 프로젝트 구조 및 설정 상태를 검증하는 스크립트
#
# 사용법: ./scripts/health-check.sh

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BOLD}Multi-Terminal Strategy - Health Check${NC}"
echo "======================================="
echo ""

errors=0
warnings=0

check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}OK${NC}   $desc ($file)"
    else
        echo -e "  ${RED}FAIL${NC} $desc ($file)"
        errors=$((errors + 1))
    fi
}

check_dir() {
    local dir=$1
    local desc=$2
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}OK${NC}   $desc ($dir/)"
    else
        echo -e "  ${RED}FAIL${NC} $desc ($dir/)"
        errors=$((errors + 1))
    fi
}

# 핵심 파일 확인
echo -e "${BOLD}[Core Files]${NC}"
check_file "CLAUDE.md" "Project constitution"
check_file "docs/architecture.md" "Architecture document"
check_file "docs/tech-stack.md" "Tech stack specification"
check_file "docs/questions.md" "Questions file"
check_file "docs/decisions.md" "Decisions record"

# 템플릿 확인
echo ""
echo -e "${BOLD}[Templates]${NC}"
check_file "docs/tasks/_template.md" "Task template"
check_file "docs/reviews/_template.md" "Review template"

# 슬래시 커맨드 확인
echo ""
echo -e "${BOLD}[Slash Commands]${NC}"
check_file ".claude/commands/architect.md" "Architect command"
check_file ".claude/commands/implementor.md" "Implementor command"
check_file ".claude/commands/reviewer.md" "Reviewer command"
check_file ".claude/commands/devops.md" "DevOps command"

# 디렉토리 구조 확인
echo ""
echo -e "${BOLD}[Directory Structure]${NC}"
check_dir "docs/tasks" "Tasks directory"
check_dir "docs/reviews" "Reviews directory"
check_dir "src" "Source code directory"
check_dir "tests" "Tests directory"
check_dir "infra" "Infrastructure directory"
check_dir "scripts" "Scripts directory"

# 스크립트 실행 권한 확인
echo ""
echo -e "${BOLD}[Script Permissions]${NC}"
for script in scripts/*.sh; do
    [ -f "$script" ] || continue
    if [ -x "$script" ]; then
        echo -e "  ${GREEN}OK${NC}   $script is executable"
    else
        echo -e "  ${YELLOW}WARN${NC} $script is not executable (run: chmod +x $script)"
        warnings=$((warnings + 1))
    fi
done

# CLAUDE.md 내용 검증
echo ""
echo -e "${BOLD}[CLAUDE.md Content]${NC}"
if [ -f "CLAUDE.md" ]; then
    if grep -q "역할별 규칙" "CLAUDE.md"; then
        echo -e "  ${GREEN}OK${NC}   Role rules defined"
    else
        echo -e "  ${YELLOW}WARN${NC} Role rules section not found"
        warnings=$((warnings + 1))
    fi
    if grep -q "코딩 컨벤션" "CLAUDE.md"; then
        echo -e "  ${GREEN}OK${NC}   Coding conventions defined"
    else
        echo -e "  ${YELLOW}WARN${NC} Coding conventions section not found"
        warnings=$((warnings + 1))
    fi
    if grep -q "Git 규칙" "CLAUDE.md"; then
        echo -e "  ${GREEN}OK${NC}   Git rules defined"
    else
        echo -e "  ${YELLOW}WARN${NC} Git rules section not found"
        warnings=$((warnings + 1))
    fi
fi

# 결과 요약
echo ""
echo "======================================="
if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All checks passed!${NC}"
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}${BOLD}Passed with $warnings warning(s)${NC}"
else
    echo -e "${RED}${BOLD}$errors error(s), $warnings warning(s)${NC}"
fi
echo ""
