"""Main FastAPI application."""

from contextlib import asynccontextmanager
from collections.abc import AsyncGenerator

from fastapi import FastAPI
from sqlalchemy import text

from app import models
from app.config import get_settings
from app.database import Base, SessionLocal, engine
from app.routes import router as task_router


settings = get_settings()


@asynccontextmanager
async def lifespan(application: FastAPI) -> AsyncGenerator[None, None]:
    """Initialize database tables when the application starts."""

    del application

    Base.metadata.create_all(bind=engine)

    yield


app = FastAPI(
    title=settings.app_name,
    version="0.2.0",
    lifespan=lifespan,
)

app.include_router(task_router)


@app.get("/")
def root() -> dict[str, str]:
    """Return basic application information."""

    return {
        "application": settings.app_name,
        "environment": settings.app_env,
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
