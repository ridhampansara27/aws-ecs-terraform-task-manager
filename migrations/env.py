"""Alembic migration environment configuration."""

from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config, pool

from app.config import get_settings
from app.database import Base
from app.models import Task


config = context.config
settings = get_settings()

# Use the same environment-based database URL as the application.
config.set_main_option(
    "sqlalchemy.url",
    settings.database_url.replace("%", "%%"),
)

# Configure Alembic logging from alembic.ini.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Make SQLAlchemy model metadata available to Alembic autogeneration.
target_metadata = Base.metadata

# Importing Task ensures the model is registered in Base.metadata.
_ = Task


def run_migrations_offline() -> None:
    """Run migrations without creating a live database connection."""

    database_url = config.get_main_option("sqlalchemy.url")

    context.configure(
        url=database_url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={
            "paramstyle": "named",
        },
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations using a live database connection."""

    connectable = engine_from_config(
        config.get_section(
            config.config_ini_section,
            {},
        ),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
