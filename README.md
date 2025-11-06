# GuideLK v2 Monorepo

This repository contains the monorepo for the GuideLK v2 platform. It includes the Flutter
mobile app, Flutter web admin console, FastAPI backend, infrastructure provisioning assets, and
documentation.

## Repository layout

```
guidelkv2/
  apps/
    mobile/          # Flutter (Android/iOS) client
    admin_web/       # Flutter Web admin panel
    api/             # FastAPI + SQLAlchemy service
  infra/
    sql/             # Alembic migrations and seed data
    apache/          # Apache configuration samples
  .env.example       # Base environment variables
```

Refer to the `README.md` files within each application directory for platform specific setup
instructions.
