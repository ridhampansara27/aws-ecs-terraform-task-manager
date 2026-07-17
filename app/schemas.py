"""Pydantic schemas used for API validation and responses."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class TaskCreate(BaseModel):
    """Data accepted when creating a task."""

    title: str = Field(
        min_length=1,
        max_length=200,
    )

    description: str | None = None

    status: str = Field(
        default="pending",
        max_length=50,
    )


class TaskResponse(TaskCreate):
    """Task data returned by the API."""

    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
