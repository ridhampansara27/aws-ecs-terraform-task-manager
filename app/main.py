"""Main FastAPI application."""

from contextlib import asynccontextmanager
from collections.abc import AsyncGenerator

from fastapi import FastAPI
from sqlalchemy import text


from app.config import get_settings
from app.database import SessionLocal
from app.routes import router as task_router
from app.middleware import SecurityHeadersMiddleware


settings = get_settings()


@asynccontextmanager
async def lifespan(application: FastAPI) -> AsyncGenerator[None, None]:
    """Manage application startup and shutdown resources."""

    del application

    yield


app = FastAPI(
    title="Cloud Native Task Manager API",
    description=(
        "A cloud-native task management REST API deployed on AWS ECS Fargate "
        "with RDS PostgreSQL, Terraform, GitHub Actions, and HTTPS."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(SecurityHeadersMiddleware)

app.include_router(task_router)


@app.get("/", tags=["System"])
def root() -> dict[str, str]:
    """Return basic application information."""

    return {
        "application": "Cloud Native Task Manager",
        "environment": settings.app_env,
        "version": "1.0.0",
        "documentation": "/docs",
        "health": "/health",
        "readiness": "/ready",
    }


@app.get("/health")
def health_check() -> dict[str, str]:
    """Confirm that the FastAPI application is running."""

    return {
        "status": "healthy",
    }


@app.get("/ready")
def readiness_check() -> dict[str, str]:
    """Confirm that the application can connect to PostgreSQL."""

    with SessionLocal() as database_session:
        database_session.execute(text("SELECT 1"))

    return {
        "status": "ready",
        "database": "connected",
    }
