# Use a stable and lightweight Python runtime.
FROM python:3.12-slim

# Prevent Python from creating compiled cache files.
ENV PYTHONDONTWRITEBYTECODE=1

# Write logs directly to the container output.
ENV PYTHONUNBUFFERED=1

# Define the working directory inside the container.
WORKDIR /app

# Create a non-root user for safer container execution.
RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser

# Copy the dependency file separately to improve Docker layer caching.
COPY requirements.txt .

# Install application dependencies.
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the FastAPI source code.
COPY app ./app

# Copy Alembic migration configuration.
COPY alembic.ini .
COPY migrations ./migrations

# Give the application user ownership of the project files.
RUN chown -R appuser:appgroup /app

# Run the application as a non-root user.
USER appuser

# Document the application port.
EXPOSE 8000

# Check that the application remains responsive.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# Start the FastAPI server.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]