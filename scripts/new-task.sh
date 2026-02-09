#!/bin/bash
# scripts/new-task.sh
# 새 Task 파일을 템플릿에서 생성하는 헬퍼 스크립트
#
# 사용법: ./scripts/new-task.sh "Task 제목"
# 예시:   ./scripts/new-task.sh "User 모듈 기본 구현"

set -e

TASKS_DIR="docs/tasks"
TEMPLATE="$TASKS_DIR/_template.md"

if [ -z "$1" ]; then
    echo "Usage: $0 \"Task 제목\""
    echo "Example: $0 \"User 모듈 기본 구현\""
    exit 1
fi

TITLE="$1"

# 다음 Task 번호 계산
last_num=$(ls "$TASKS_DIR"/TASK-*.md 2>/dev/null | sed 's/.*TASK-\([0-9]*\)\.md/\1/' | sort -n | tail -1)
if [ -z "$last_num" ]; then
    next_num=1
else
    next_num=$((last_num + 1))
fi
TASK_NUM=$(printf "%03d" $next_num)
TASK_FILE="$TASKS_DIR/TASK-${TASK_NUM}.md"
TODAY=$(date '+%Y-%m-%d')

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template not found at $TEMPLATE"
    exit 1
fi

# 템플릿에서 Task 파일 생성
sed -e "s/{NUMBER}/$TASK_NUM/g" \
    -e "s/{제목}/$TITLE/g" \
    -e "s/{날짜}/$TODAY/g" \
    -e "s/PENDING | IN_PROGRESS | REVIEW | DONE/PENDING/" \
    -e "s/HIGH | MEDIUM | LOW/MEDIUM/" \
    "$TEMPLATE" > "$TASK_FILE"

echo "Created: $TASK_FILE"
echo "Edit the file to fill in requirements and acceptance criteria."
