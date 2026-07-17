"""Database operations for task resources."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Task
from app.schemas import TaskCreate, TaskUpdate


def create_task(
    database_session: Session,
    task_data: TaskCreate,
) -> Task:
    """Create and store a new task."""

    task = Task(
        title=task_data.title,
        description=task_data.description,
        status=task_data.status,
    )

    database_session.add(task)
    database_session.commit()
    database_session.refresh(task)

    return task


def get_tasks(
    database_session: Session,
) -> list[Task]:
    """Return all tasks ordered by newest ID first."""

    statement = select(Task).order_by(Task.id.desc())

    return list(database_session.scalars(statement).all())


def get_task_by_id(
    database_session: Session,
    task_id: int,
) -> Task | None:
    """Return one task by its ID."""

    return database_session.get(Task, task_id)


def update_task(
    database_session: Session,
    task: Task,
    task_data: TaskUpdate,
) -> Task:
    """Update the provided task using supplied fields only."""

    update_values = task_data.model_dump(exclude_unset=True)

    for field_name, field_value in update_values.items():
        setattr(task, field_name, field_value)

    database_session.commit()
    database_session.refresh(task)

    return task


def delete_task(
    database_session: Session,
    task: Task,
) -> None:
    """Delete the provided task."""

    database_session.delete(task)
    database_session.commit()
