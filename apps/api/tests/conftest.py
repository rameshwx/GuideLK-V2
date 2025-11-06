import os
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault(
    "SQLALCHEMY_DATABASE_URI",
    "sqlite+pysqlite:///:memory:",
)

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from app.core.database import SessionLocal, engine
from app.main import app
from app.models import Base, User
from app.dependencies import get_current_user


@pytest.fixture(autouse=True)
def reset_database() -> None:
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield


@pytest.fixture
def db_session():
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture
def auth_user(db_session):
    user = User(firebase_uid="test-user", email="test@example.com")
    db_session.add(user)
    db_session.commit()
    return user


@pytest.fixture
def client(auth_user):
    app.dependency_overrides[get_current_user] = lambda: auth_user
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.pop(get_current_user, None)
