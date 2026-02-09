#!/bin/bash
# scripts/new-review.sh
# 새 Review 파일을 템플릿에서 생성하는 헬퍼 스크립트
#
# 사용법: ./scripts/new-review.sh TASK-001
# 예시:   ./scripts/new-review.sh TASK-001

set -e

REVIEWS_DIR="docs/reviews"
TEMPLATE="$REVIEWS_DIR/_template.md"

if [ -z "$1" ]; then
    echo "Usage: $0 TASK-XXX"
    echo "Example: $0 TASK-001"
    exit 1
fi

TASK_ID="$1"
TASK_NUM=$(echo "$TASK_ID" | sed 's/TASK-//')

REVIEW_FILE="$REVIEWS_DIR/REVIEW-${TASK_NUM}.md"
TODAY=$(date '+%Y-%m-%d')

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template not found at $TEMPLATE"
    exit 1
fi

if [ -f "$REVIEW_FILE" ]; then
    echo "Warning: $REVIEW_FILE already exists. Overwrite? (y/N)"
    read -r answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

# 템플릿에서 Review 파일 생성
sed -e "s/{NUMBER}/$TASK_NUM/g" \
    -e "s/{날짜}/$TODAY/g" \
    -e "s/PASS | FAIL | CONDITIONAL_PASS//" \
    "$TEMPLATE" > "$REVIEW_FILE"

echo "Created: $REVIEW_FILE"
echo "Edit the file to fill in review results."
