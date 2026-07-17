"""Tests for task CRUD endpoints."""

from collections.abc import Generator

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.database import Base, get_database_session
from app.main import app


test_engine = create_engine(
    "sqlite://",
    connect_args={
        "check_same_thread": False,
    },
    poolclass=StaticPool,
)

TestSessionLocal = sessionmaker(
    bind=test_engine,
    autoflush=False,
    autocommit=False,
)


def override_database_session() -> Generator[Session, None, None]:
    """Provide an isolated SQLite database session for tests."""

    database_session = TestSessionLocal()

    try:
        yield database_session
    finally:
        database_session.close()


app.dependency_overrides[get_database_session] = override_database_session

client = TestClient(app)


def setup_function() -> None:
    """Recreate database tables before every test."""

    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)


def test_create_task() -> None:
    """A task should be created successfully."""

    response = client.post(
        "/tasks",
        json={
            "title": "Create Terraform configuration",
            "description": "Build the initial VPC module",
            "status": "pending",
        },
    )

    assert response.status_code == 201

    response_data = response.json()

    assert response_data["id"] == 1
    assert response_data["title"] == "Create Terraform configuration"
    assert response_data["status"] == "pending"


def test_list_tasks() -> None:
    """The API should return all stored tasks."""

    client.post(
        "/tasks",
        json={
            "title": "Build Docker image",
            "status": "pending",
        },
    )

    response = client.get("/tasks")

    assert response.status_code == 200
    assert len(response.json()) == 1


def test_missing_task_returns_404() -> None:
    """An unknown task ID should return HTTP 404."""

    response = client.get("/tasks/999")

    assert response.status_code == 404
    assert response.json() == {
        "detail": "Task not found",
    }


def test_update_task() -> None:
    """An existing task should be updated."""

    create_response = client.post(
        "/tasks",
        json={
            "title": "Deploy ECS service",
            "status": "pending",
        },
    )

    task_id = create_response.json()["id"]

    response = client.put(
        f"/tasks/{task_id}",
        json={
            "status": "completed",
        },
    )

    assert response.status_code == 200
    assert response.json()["status"] == "completed"


def test_delete_task() -> None:
    """An existing task should be deleted."""

    create_response = client.post(
        "/tasks",
        json={
            "title": "Configure CloudWatch",
            "status": "pending",
        },
    )

    task_id = create_response.json()["id"]

    delete_response = client.delete(f"/tasks/{task_id}")

    assert delete_response.status_code == 204

    get_response = client.get(f"/tasks/{task_id}")

    assert get_response.status_code == 404
