# Database migrations

Alembic migration scaffolding for the GuideLK API. Initialize the environment by running:

```bash
alembic init migrations
```

This repository provides a starting `env.py` and sample migration under `infra/sql/versions`.
Run migrations against the configured MySQL database:

```bash
alembic upgrade head
```
