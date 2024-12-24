#!/bin/bash

get_task() {
  if [ -z "$TASK" ]; then
    echo -n "Enter task description: "
    read TASK
  fi
}

get_tags() {
  echo -n "Enter comma-separated tags (Default: NONE): "
  read TAGS
  [ -z "$TAGS" ] && TAGS="none"
}

get_deadline() {
  echo -n "Enter deadline (YYYY-MM-DD) (Default: TODAY): "
  read DEADLINE
  [ -z "$DEADLINE" ] && DEADLINE=$(date "+%Y-%m-%d%n")
}

get_priority() {
  echo -n "Enter priority (low/medium/high) (Default: MEDIUM): "
  read PRIORITY
  [ -z "$PRIORITY" ] && PRIORITY="medium"
}

generate_id() {
  LAST_ID=$(grep -E '^ID:[0-9]+' "$0" | awk -F ':' '{print $2}' | awk '{print $1}' | sort -n | tail -n 1)
  if [ -z "$LAST_ID" ]; then
    echo 1
  else
    echo $((LAST_ID + 1))
  fi
}

add_task() {
  get_task
  get_tags
  get_deadline
  get_priority
  ID=$(generate_id)
  TMP_FILE=$(mktemp)

  awk -v id="ID:$ID TASK:$TASK TAGS:$TAGS DEADLINE:$DEADLINE PRIORITY:$PRIORITY" '
    /^TASKLISTEND$/ { print id }
    { print }
  ' "$0" > "$TMP_FILE"

  mv "$TMP_FILE" "$0"
  chmod +x "$0"
  echo "Task added with ID: $ID"
  $0 show
}

del_task() {
  TASK=$(grep '^ID:[0-9]\+ ' "$0" | fzf --no-border --no-preview --height=10 --prompt="Select task to delete: " | awk '{print $1}' | cut -d: -f2)
  if [ -n "$TASK" ]; then
    TMP_FILE=$(mktemp)

    sed "/^ID:$TASK /d" "$0" > "$TMP_FILE"

    awk '
      BEGIN { id=1 }
      /^ID:[0-9]+ / {
        sub(/^ID:[0-9]+/, "ID:" id)
        id++
      }
      { print }
    ' "$TMP_FILE" > "$0"

    chmod +x "$0"
    echo "Task with ID $TASK deleted and tasks renumbered."
    $0 show
  else
    echo "No task selected."
  fi
}

mark_done_task() {
  TASK=$(grep '^ID:[0-9]\+ TASK:' "$0" | fzf --no-border --no-preview --height=10 --prompt="Select task to mark as done: ")
  if [ -n "$TASK" ]; then
    ID=$(echo "$TASK" | awk '{print $1}' | cut -d: -f2)
    TMP_FILE=$(mktemp)
    awk -v id="ID:$ID" '
      $0 ~ id { sub(/TASK:/, "[DONE] TASK:") }
      { print }
    ' "$0" > "$TMP_FILE"
    mv "$TMP_FILE" "$0"
    chmod +x "$0"
    echo "Task with ID $ID marked as done."
  else
    echo "No task selected."
  fi
}

show_task() {
  echo -e "\033[1;34m----------ACTIVE TASKS----------\033[0m"
  grep '^ID:' "$0" | grep -v '\[DONE\]' | sed -E 's/(PRIORITY:.*)$/\1\x1b[0m/'
  if ! grep '^ID:' "$0" | grep -v '\[DONE\]' &>/dev/null; then
    echo -e "\033[1;31mNo active tasks found.\033[0m"
  fi
  echo -e "\033[1;34m--------------------------------\033[0m"

  echo -e "\033[1;32m----------COMPLETED TASKS----------\033[0m"
  grep '^ID:' "$0" | grep '\[DONE\]' | sed -E 's/(PRIORITY:.*)$/\1\x1b[0m/'
  if ! grep '^ID:' "$0" | grep '\[DONE\]' &>/dev/null; then
    echo -e "\033[1;31mNo completed tasks found.\033[0m"
  fi
  echo -e "\033[1;32m-----------------------------------\033[0m"
}

show_help() {
  cat << EOF

Description: script which keeps tasks list (or any other list) inside itself
Usage: $0 [add|del|show|mark_done]

Commands:
  add [task description]         Add a new task
  del                            Delete a task (interactive)
  show                           Show all tasks
  mark_done                      Mark a task as done

EOF
  exit
}

fzf_menu() {
  # $0 show
  COMMAND=$(printf "add\nshow\ndel\nmark_done" | fzf --no-border --no-preview --height=6 --prompt="Select command: ")
  case $COMMAND in
    add)
      $0 add
      ;;
    show)
      $0 show
      ;;
    del)
      $0 del
      ;;
    mark_done)
      $0 mark_done
      ;;
    *)
      echo "No command selected."
      ;;
  esac
}

if [ -z "$1" ]; then
  fzf_menu
else
  case $1 in
    add|del|show|mark_done)
      ACTION=$1
      shift
      TASK="$@"
      ${ACTION}_task
      ;;
    *)
      show_help
      ;;
  esac
fi

exit

TASKLISTSTART
ID:1 [DONE] TASK:test TAGS:none DEADLINE:2024-12-24 PRIORITY:medium
ID:2 TASK:Test TAGS:none DEADLINE:2024-12-24 PRIORITY:medium
TASKLISTEND
