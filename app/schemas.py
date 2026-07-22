"""Pydantic schemas used for request validation and API responses."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class TaskBase(BaseModel):
    """Common fields shared by task schemas."""

    title: str = Field(
        min_length=1,
        max_length=200,
    )

    description: str | None = None

    status: str = Field(
        default="pending",
        min_length=1,
        max_length=50,
    )

    priority: str = Field(
        default="medium",
        min_length=1,
        max_length=50,
    )


class TaskCreate(TaskBase):
    """Data required when creating a task."""

    pass


class TaskUpdate(BaseModel):
    """Optional fields that can be changed on an existing task."""

    title: str | None = Field(
        default=None,
        min_length=1,
        max_length=200,
    )

    description: str | None = None

    status: str | None = Field(
        default=None,
        min_length=1,
        max_length=50,
    )

    priority: str | None = Field(
        default=None,
        min_length=1,
        max_length=50,
    )


class TaskResponse(TaskBase):
    """Task data returned by the API."""

    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)