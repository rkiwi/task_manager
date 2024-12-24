# Task Manager Script

This script is a simple task manager written in Bash. It allows you to manage a list of tasks directly within the script itself. Tasks can be added, deleted, marked as done, and displayed in an interactive menu.

---

## Features

- **Add Tasks**: Add new tasks with a description, tags, deadline, and priority.
- **Delete Tasks**: Select and delete tasks interactively, with automatic renumbering of IDs.
- **Mark Tasks as Done**: Mark tasks as completed, with a strike-through effect when displayed.
- **Show Tasks**: Display all tasks, including active and completed ones.
- **Interactive Menu**: Use `fzf` for an interactive and user-friendly task management experience.

---

## Requirements

- Bash shell
- [`fzf`](https://github.com/junegunn/fzf) for interactive menu selection

---

## How It Works

The script keeps the task list within itself, which means all tasks are saved in the script file. Each task has the following attributes:

- **ID**: A unique identifier for the task, auto-incremented.
- **Description**: A brief description of the task.
- **Tags**: Comma-separated tags for categorizing the task (default: `none`).
- **Deadline**: A due date for the task in `YYYY-MM-DD` format (default: today's date).
- **Priority**: The importance of the task (`low`, `medium`, `high`; default: `medium`).

---

## Usage

Run the script directly in your terminal to open the interactive menu:

```bash
./task_manager.sh
```
You can also use the following commands:

### Add a Task

```bash
./task_manager.sh add
```
Prompts you to enter:
	•	A description of the task
	•	Tags (optional)
	•	A deadline (optional; defaults to today’s date)
	•	Priority (optional; defaults to medium)

### Show Tasks

```bash
./task_manager.sh show
```
Displays all tasks. Completed tasks are shown with a strike-through effect.

### Delete a Task

```bash
./task_manager.sh del
```
Opens an interactive menu (via fzf) to select and delete a task. Task IDs are automatically renumbered after deletion.

### Mark a Task as Done

```bash
./task_manager.sh mark_done
```
Opens an interactive menu (via fzf) to select a task and mark it as completed.

---

## Task List Format

Tasks are stored within the script in the following format:

```
ID:1 TASK:Sample Task TAGS:none DEADLINE:2024-12-24 PRIORITY:medium
```

Completed tasks will appear as:

```
ID:1 [DONE] TASK:Sample Task TAGS:none DEADLINE:2024-12-24 PRIORITY:medium
```
