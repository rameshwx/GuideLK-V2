import os

os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault("SQLALCHEMY_DATABASE_URI", "sqlite+pysqlite:///:memory:")

from fastapi.testclient import TestClient
import pytest

from app.main import app


@pytest.fixture
def client() -> TestClient:
    with TestClient(app) as test_client:
        yield test_client
