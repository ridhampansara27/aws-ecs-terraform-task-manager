"""Tests for application health endpoints."""

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_endpoint() -> None:
    """The health endpoint should return HTTP 200."""

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "status": "healthy",
    }


def test_root_endpoint() -> None:
    response = client.get("/")

    assert response.status_code == 200

    payload = response.json()

    assert payload["application"] == "Cloud Native Task Manager"
    assert payload["environment"] == "development"
    assert payload["version"] == "1.0.0"
    assert payload["documentation"] == "/docs"
