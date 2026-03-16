# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

# Set the working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy project files
COPY pyproject.toml uv.lock ./

# Install dependencies
# Using --no-install-project to only install dependencies first (layer caching)
RUN uv sync --frozen --no-dev --no-install-project

# Final image
FROM python:3.12-slim-bookworm

WORKDIR /app

# Copy the environment from the builder
COPY --from=builder /app/.venv /app/.venv

# Copy the application code
COPY server.py .

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV MCP_TRANSPORT=http
ENV PYTHONUNBUFFERED=1

# Expose the port (FastMCP HTTP defaults to 8000)
EXPOSE 8000

# Run the server
CMD ["python", "server.py"]
