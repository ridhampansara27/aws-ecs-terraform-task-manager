"""FastAPI routes for task-management operations."""

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app import crud
from app.database import get_database_session
from app.schemas import TaskCreate, TaskResponse, TaskUpdate


router = APIRouter(
    prefix="/tasks",
    tags=["Tasks"],
)


@router.post(
    "",
    response_model=TaskResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_task(
    task_data: TaskCreate,
    database_session: Session = Depends(get_database_session),
) -> TaskResponse:
    """Create a new task."""

    return crud.create_task(
        database_session=database_session,
        task_data=task_data,
    )


@router.get(
    "",
    response_model=list[TaskResponse],
)
def list_tasks(
    database_session: Session = Depends(get_database_session),
) -> list[TaskResponse]:
    """Return every stored task."""

    return crud.get_tasks(database_session)


@router.get(
    "/{task_id}",
    response_model=TaskResponse,
)
def get_task(
    task_id: int,
    database_session: Session = Depends(get_database_session),
) -> TaskResponse:
    """Return one task by ID."""

    task = crud.get_task_by_id(
        database_session=database_session,
        task_id=task_id,
    )

    if task is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found",
        )

    return task


@router.put(
    "/{task_id}",
    response_model=TaskResponse,
)
def update_task(
    task_id: int,
    task_data: TaskUpdate,
    database_session: Session = Depends(get_database_session),
) -> TaskResponse:
    """Update an existing task."""

    task = crud.get_task_by_id(
        database_session=database_session,
        task_id=task_id,
    )

    if task is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found",
        )

    return crud.update_task(
        database_session=database_session,
        task=task,
        task_data=task_data,
    )


@router.delete(
    "/{task_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_task(
    task_id: int,
    database_session: Session = Depends(get_database_session),
) -> Response:
    """Delete an existing task."""

    task = crud.get_task_by_id(
        database_session=database_session,
        task_id=task_id,
    )

    if task is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found",
        )

    crud.delete_task(
        database_session=database_session,
        task=task,
    )

    return Response(status_code=status.HTTP_204_NO_CONTENT)
