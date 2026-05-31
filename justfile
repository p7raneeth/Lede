project := "lede"

set dotenv-load := false

# ──────────────────────────────────────────────
# Project Scaffolding
# ──────────────────────────────────────────────

# Create directory structure
setup:
    mkdir -p {{project}}/backend/api
    mkdir -p {{project}}/backend/core
    mkdir -p {{project}}/backend/repositories
    mkdir -p {{project}}/backend/services
    mkdir -p {{project}}/backend/scripts
    mkdir -p {{project}}/backend/alembic
    mkdir -p {{project}}/frontend/public
    mkdir -p {{project}}/frontend/src
    touch {{project}}/README.md
    touch {{project}}/backend/.env
    touch {{project}}/backend/app_factory.py
    touch {{project}}/backend/database.py
    touch {{project}}/backend/main.py
    touch {{project}}/backend/models.py
    touch {{project}}/backend/schemas.py
    touch {{project}}/backend/requirements.txt

# Initialize git and create .gitignore
init-git:
    git init
    touch {{project}}/.gitignore
    echo "__pycache__/" >> {{project}}/.gitignore
    echo "*.py[cod]" >> {{project}}/.gitignore
    echo ".venv/" >> {{project}}/.gitignore
    echo "venv/" >> {{project}}/.gitignore
    echo ".env" >> {{project}}/.gitignore
    echo "node_modules/" >> {{project}}/.gitignore
    echo "dist/" >> {{project}}/.gitignore
    echo "build/" >> {{project}}/.gitignore
    echo ".vscode/" >> {{project}}/.gitignore
    echo ".idea/" >> {{project}}/.gitignore
    echo ".DS_Store" >> {{project}}/.gitignore
    echo "*.db" >> {{project}}/.gitignore

# Create project, initialize git, and make first commit
scaffold: setup init-git
    git add .
    git commit -m "Initial project scaffold"

# Show project tree
tree:
    tree {{project}}

# Delete entire project
clean:
    rm -rf {{project}}

# ──────────────────────────────────────────────
# Docker / Infrastructure
# ──────────────────────────────────────────────

# Start all infra (Postgres + Redis)
infra-up:
    docker-compose up -d
    @echo "✓ Postgres running on localhost:5432"
    @echo "✓ Redis running on localhost:6379"

# Stop all infra
infra-down:
    docker-compose down

# Stop all infra and wipe data volumes
infra-reset:
    docker-compose down -v
    @echo "✓ Volumes wiped — clean slate"

# Start only Postgres
pg-up:
    docker-compose up -d postgres
    @echo "✓ Postgres running on localhost:5432"

# Start only Redis
redis-up:
    docker-compose up -d redis
    @echo "✓ Redis running on localhost:6379"

# Connect to Postgres shell
pg-shell:
    docker exec -it lede-postgres psql -U lede_admin -d lede_db

# Connect to Redis CLI
redis-shell:
    docker exec -it lede-redis redis-cli

# Check infra health
infra-status:
    @echo "── Postgres ──"
    @docker exec lede-postgres pg_isready -U lede_admin -d lede_db 2>/dev/null || echo "✗ Postgres not running"
    @echo "── Redis ──"
    @docker exec lede-redis redis-cli ping 2>/dev/null || echo "✗ Redis not running"

# View Postgres logs
pg-logs:
    docker-compose logs -f postgres

# View Redis logs
redis-logs:
    docker-compose logs -f redis

# ──────────────────────────────────────────────
# FastAPI
# ──────────────────────────────────────────────

# Run the API server (dev mode with reload)
dev:
    cd {{project}}/backend && uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Run the API server (production mode)
serve:
    cd {{project}}/backend && uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4

# ──────────────────────────────────────────────
# Database Migrations (Alembic)
# ──────────────────────────────────────────────

# Generate a new migration from model changes
migrate-generate message:
    cd {{project}}/backend && alembic revision --autogenerate -m "{{message}}"

# Run all pending migrations
migrate-up:
    cd {{project}}/backend && alembic upgrade head

# Rollback last migration
migrate-down:
    cd {{project}}/backend && alembic downgrade -1

# Show current migration status
migrate-status:
    cd {{project}}/backend && alembic current

# Show migration history
migrate-history:
    cd {{project}}/backend && alembic history --verbose

# ──────────────────────────────────────────────
# Testing & Quality
# ──────────────────────────────────────────────

# Run all tests
test:
    cd {{project}}/backend && pytest -v

# Run tests with coverage
test-cov:
    cd {{project}}/backend && pytest --cov=. --cov-report=term-missing -v

# Lint with ruff
lint:
    cd {{project}}/backend && ruff check .

# Lint and auto-fix
lint-fix:
    cd {{project}}/backend && ruff check --fix .

# Format with ruff
fmt:
    cd {{project}}/backend && ruff format .

# ──────────────────────────────────────────────
# Seeds & Scripts
# ──────────────────────────────────────────────

# Seed database with mock data
seed:
    cd {{project}}/backend && python -m scripts.seed

# ──────────────────────────────────────────────
# Shortcuts
# ──────────────────────────────────────────────

# Full bootstrap: scaffold + infra + migrations + seed + dev server
bootstrap: scaffold infra-up migrate-up seed dev

# Quick start: infra + dev server (assumes project exists and DB is migrated)
start: infra-up dev

# List all available commands
help:
    @just --list