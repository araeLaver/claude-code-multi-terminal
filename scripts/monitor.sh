#!/bin/bash
# scripts/monitor.sh
# 프로젝트 상태 모니터링 스크립트
# 터미널 간 전환 타이밍을 알려주는 보조 도구
#
# 사용법: ./scripts/monitor.sh
# 종료: Ctrl+C

TASKS_DIR="docs/tasks"
REVIEWS_DIR="docs/reviews"
QUESTIONS_FILE="docs/questions.md"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${CYAN}Project Status Monitor started. Press Ctrl+C to exit.${NC}"
echo ""

while true; do
    clear
    echo -e "${BOLD}=======================================${NC}"
    echo -e "${BOLD} Multi-Terminal Project Monitor${NC}"
    echo -e "${BOLD} $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${BOLD}=======================================${NC}"

    # Task 상태 요약
    echo ""
    echo -e "${BLUE}[Tasks]${NC}"
    pending=0
    in_progress=0
    review=0
    done_count=0
    for f in "$TASKS_DIR"/TASK-*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        status=$(grep "^## 상태:" "$f" 2>/dev/null | head -1 | sed 's/## 상태: //' | awk '{print $1}')
        case "$status" in
            PENDING)
                echo -e "  ${YELLOW}PENDING${NC}      $name"
                pending=$((pending + 1))
                ;;
            IN_PROGRESS)
                echo -e "  ${CYAN}IN_PROGRESS${NC}  $name"
                in_progress=$((in_progress + 1))
                ;;
            REVIEW)
                echo -e "  ${RED}REVIEW${NC}       $name"
                review=$((review + 1))
                ;;
            DONE)
                echo -e "  ${GREEN}DONE${NC}         $name"
                done_count=$((done_count + 1))
                ;;
            *)
                echo -e "  ???          $name"
                ;;
        esac
    done
    if [ $((pending + in_progress + review + done_count)) -eq 0 ]; then
        echo "  (no tasks found)"
    fi
    echo ""
    echo -e "  Summary: ${YELLOW}$pending pending${NC} | ${CYAN}$in_progress in progress${NC} | ${RED}$review in review${NC} | ${GREEN}$done_count done${NC}"

    # Review 상태 요약
    echo ""
    echo -e "${BLUE}[Reviews]${NC}"
    has_reviews=false
    for f in "$REVIEWS_DIR"/REVIEW-*.md; do
        [ -f "$f" ] || continue
        has_reviews=true
        name=$(basename "$f" .md)
        status=$(grep "^## 상태:" "$f" 2>/dev/null | head -1 | sed 's/## 상태: //' | awk '{print $1}')
        case "$status" in
            PASS)
                echo -e "  ${GREEN}PASS${NC}               $name"
                ;;
            FAIL)
                echo -e "  ${RED}FAIL${NC}               $name"
                ;;
            CONDITIONAL_PASS)
                echo -e "  ${YELLOW}CONDITIONAL_PASS${NC}   $name"
                ;;
            *)
                echo -e "  ???                $name"
                ;;
        esac
    done
    if [ "$has_reviews" = false ]; then
        echo "  (no reviews found)"
    fi

    # 미응답 질의 확인
    echo ""
    echo -e "${BLUE}[Open Questions]${NC}"
    if [ -f "$QUESTIONS_FILE" ]; then
        open_count=$(grep -c "상태: OPEN" "$QUESTIONS_FILE" 2>/dev/null || echo 0)
        if [ "$open_count" -gt 0 ]; then
            echo -e "  ${YELLOW}$open_count open question(s)${NC}"
        else
            echo "  (none)"
        fi
    else
        echo "  (questions.md not found)"
    fi

    # 알림 섹션
    echo ""
    echo -e "${BOLD}=======================================${NC}"
    echo -e "${BOLD} Notifications${NC}"
    echo -e "${BOLD}=======================================${NC}"

    has_notification=false

    # REVIEW 상태 Task가 있으면 알림
    if [ "$review" -gt 0 ]; then
        echo -e "  ${RED}>> Terminal 3 (Reviewer): $review task(s) awaiting review!${NC}"
        has_notification=true
    fi

    # PENDING 상태 Task가 있으면 알림
    if [ "$pending" -gt 0 ]; then
        echo -e "  ${YELLOW}>> Terminal 2 (Implementor): $pending task(s) pending!${NC}"
        has_notification=true
    fi

    # OPEN 질의가 있으면 알림
    if [ -f "$QUESTIONS_FILE" ] && grep -q "상태: OPEN" "$QUESTIONS_FILE" 2>/dev/null; then
        echo -e "  ${YELLOW}>> Terminal 1 (Architect): Open questions need answers!${NC}"
        has_notification=true
    fi

    # FAIL 리뷰가 있으면 알림
    if ls "$REVIEWS_DIR"/REVIEW-*.md 1>/dev/null 2>&1; then
        fail_count=$(grep -rl "상태: FAIL\|상태: CONDITIONAL_PASS" "$REVIEWS_DIR"/ 2>/dev/null | wc -l)
        if [ "$fail_count" -gt 0 ]; then
            echo -e "  ${RED}>> Terminal 2 (Implementor): $fail_count review(s) need fixes!${NC}"
            has_notification=true
        fi
    fi

    if [ "$has_notification" = false ]; then
        echo -e "  ${GREEN}All clear. No pending actions.${NC}"
    fi

    echo ""
    echo -e "${CYAN}Refreshing every 10 seconds...${NC}"
    sleep 10
done
