"""Application configuration loaded from environment variables."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuration values used by the application."""

    app_name: str = "Cloud Native Task Manager"
    app_env: str = "development"
    app_port: int = 8000

    database_url: str = (
        "postgresql+psycopg://"
        "taskuser:local-development-password@localhost:5432/taskmanager"
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Return one reusable settings instance."""

    return Settings()
